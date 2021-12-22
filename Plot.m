clc;
clear;

A = importdata("data.txt");
probs = importdata("probs.txt");

d_x_vals = A(:, 1);
d_y_vals1 = A(:, 2);
d_y_vals2 = A(:, 3);

x_vals = linspace(d_x_vals(1), d_x_vals(end), 10000);
y_vals1 = interp1(d_x_vals, d_y_vals1, x_vals, 'spline');
y_vals2 = interp1(d_x_vals, d_y_vals2, x_vals, 'spline');

c = linspace(0, 1, length(x_vals));
c2 = interp1(x_vals, c, d_x_vals);

figure; set(gcf, 'position', [10 50 800 600]);
subplot(2, 1, 1); hold on;
b = bar(d_x_vals, d_y_vals1, 'FaceColor', 'flat');
scatter(x_vals, y_vals1, 0.5, c);
b.CData = c2'; %set(gca, 'xscale', 'log');

title('PMF');
xlabel('Number of Runs'); ylabel('Frequency');
ax = gca; ax.YGrid = 'on'; ax.XGrid = 'on';
cmap = colormap(jet(length(x_vals)));


y = get(gca, 'YLim')*1.75;
[~, i] = max(y_vals1); val = x_vals(i);
plot([val val], y, 'Color', cmap(i, :));
text(val, y(2)*0.8,...
    sprintf([' Mode\n' ' x = ' num2str(val)...%'\n y = ' num2str(y_vals1(i)*100,'%.3f') '%%'...
    '\n A = ' num2str(y_vals2(i)*100,'%.3f') '%%']), 'VerticalAlignment', 'bottom');

[~, i] = max(y_vals2 >= 0.5); val = x_vals(i);
plot([val val], y, 'Color', cmap(i, :));
text(val, y(2)*0.6125,...
    sprintf([' Median\n' ' x = ' num2str(val)...%'\n y = ' num2str(y_vals1(i)*100,'%.3f') '%%'...
    '\n A = 50%%']), 'VerticalAlignment', 'bottom');

val = averageRun(probs); [~, i] = max(x_vals >= val);
plot([val val], y, 'Color', cmap(i, :));
text(val, y(2)*0.425,...
    sprintf([' Average\n' ' x = ' num2str(val)...%'\n y = ' num2str(y_vals1(i)*100,'%.3f') '%%'...
    '\n A = ' num2str(y_vals2(i)*100,'%.3f') '%%']), 'VerticalAlignment', 'bottom');

[~, i] = max(y_vals2 >= 0.99); val = x_vals(i);
plot([val val], y, 'Color', cmap(i, :));
text(val, y(2)*0.8,...
    sprintf([' x = ' num2str(val)...%'\n y = ' num2str(y_vals1(i)*100,'%.3f') '%%'...
    '\n A = 99%%']), 'VerticalAlignment', 'bottom');

[~, i] = max(y_vals2 >= 0.999); val = x_vals(i);
plot([val val], y, 'Color', cmap(i, :));
text(val, y(2)*0.65,...
    sprintf([' x = ' num2str(val)...%'\n y = ' num2str(y_vals1(i)*100,'%.3f') '%%'...
    '\n A = 99.9%%']), 'VerticalAlignment', 'bottom');

[~, i] = max(y_vals2 >= 0.9999); val = x_vals(i);
plot([val val], y, 'Color', cmap(i, :));
text(val, y(2)*0.5,...
    sprintf([' x = ' num2str(val)...%'\n y = ' num2str(y_vals1(i)*100,'%.3f') '%%'...
    '\n A = 99.99%%']), 'VerticalAlignment', 'bottom');
set(gca, 'YLim', y); hold off;


subplot(2, 1, 2); hold on;
b = bar(d_x_vals, d_y_vals2, 'FaceColor', 'flat');
scatter(x_vals, y_vals2, 0.5, c);
b.CData = c2'; %set(gca, 'xscale', 'log');

title('CDF');
xlabel('Number of Runs'); ylabel('Probability');
ax = gca; ax.YGrid = 'on'; ax.XGrid = 'on';


[~, i] = max(y_vals1); val = x_vals(i);
plot([val val], [0 2], 'Color', cmap(i, :));

[~, i] = max(y_vals2 >= 0.5); val = x_vals(i);
plot([val val], [0 2], 'Color', cmap(i, :));

val = averageRun(probs); [~, i] = max(x_vals >= val);
plot([val val], [0 2], 'Color', cmap(i, :));

[~, i] = max(y_vals2 >= 0.99); val = x_vals(i);
plot([val val], [0 2], 'Color', cmap(i, :));

[~, i] = max(y_vals2 >= 0.999); val = x_vals(i);
plot([val val], [0 2], 'Color', cmap(i, :));

[~, i] = max(y_vals2 >= 0.9999); val = x_vals(i);
plot([val val], [0 2], 'Color', cmap(i, :));
set(gca, 'YLim', [0 1], 'Clipping', 'off');
hold off;


function [runs] = averageRun(varargin)
probs = cell2mat(varargin); sumP = sum(probs);
if sumP <= 0
    runs = 0;
    return
elseif sumP > 1
    probs = probs/sumP;
    sumP = 1;
end

runs = 1;
for i = 1:length(probs)
    probArray = probs; probArray(i) = [];
    run = averageRun(probArray);
    runs = runs + probs(i)*run;
end

runs = runs/sumP;
end
