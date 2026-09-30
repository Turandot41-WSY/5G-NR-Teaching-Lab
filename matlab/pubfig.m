classdef pubfig
% Publication style for every MATLAB figure in the knowledge base.
% Every text element is at least 18 pt, lines and markers stay visible after the
% figure is scaled to the reading column, titles are wrapped so nothing leaves the
% canvas, text overlaps are detected, constellations get a square canvas, and the
% export is a 300 dpi PNG plus a vector PDF on a white background.
methods (Static)
    function f = new(~)
        f = figure('Visible','off','Color','w','Theme','light','Units','inches','Position',[1 1 6.6 4.2],'InvertHardcopy','off');
        set(f,'DefaultAxesFontSize',18,'DefaultAxesFontName','Helvetica','DefaultTextFontSize',18,'DefaultTextFontName','Helvetica', ...
            'DefaultLegendFontSize',18,'DefaultColorbarFontSize',18,'DefaultAxesTitleFontSizeMultiplier',1,'DefaultAxesLabelFontSizeMultiplier',1, ...
            'DefaultAxesTitleFontWeight','bold','DefaultLineLineWidth',2,'DefaultLineMarkerSize',7,'DefaultStairLineWidth',2, ...
            'DefaultErrorbarLineWidth',2,'DefaultErrorbarCapSize',8,'DefaultAxesLineWidth',1,'DefaultAxesBox','on', ...
            'DefaultAxesXColor','k','DefaultAxesYColor','k','DefaultAxesColor','w','DefaultAxesGridAlpha',0.25,'DefaultConstantlineLineWidth',1.8, ...
            'DefaultAxesColorOrder',[0 0.45 0.74; 0.85 0.33 0.10; 0.47 0.67 0.19; 0.49 0.18 0.56; 0.93 0.69 0.13; 0.30 0.75 0.93; 0.64 0.08 0.18]);
    end
    function export(f, pngPath)
        [~,name] = fileparts(pngPath);
        [f, temporary] = pubfig.restack(f);
        pubfig.floor(f);
        pubfig.layout(f);
        % The 18 pt floor applied by check() shrinks the axes, so dodge the legends again until nothing is hidden.
        for pass = 1:3
            pubfig.check(f, name); pubfig.dodge(f); drawnow;
            if ~pubfig.anyCovered(f), break; end
        end
        problems = pubfig.check(f, name);
        for k = 1:numel(problems), fprintf('PUBFIG PROBLEM %s\n', problems{k}); end
        pubfig.record(problems);
        exportgraphics(f, pngPath, 'Resolution', 300, 'BackgroundColor', 'white');
        exportgraphics(f, regexprep(pngPath, '\.png$', '.pdf'), 'ContentType', 'vector', 'BackgroundColor', 'white');
        if temporary, close(f); end
    end
    function [g, moved] = restack(f)
        % Side-by-side panels shrink to half a column on the site. Move them into a
        % fresh vertical layout in a new figure so each panel keeps the full width.
        g = f; moved = false;
        axs = findall(f, 'Type', 'axes'); axs = axs(arrayfun(@(a) ~isa(a, 'matlab.graphics.axis.PolarAxes'), axs));
        if numel(axs) < 2, return; end
        for a = axs', a.Units = 'normalized'; end
        px = round(cell2mat(arrayfun(@(a) a.OuterPosition(1), axs, 'UniformOutput', false)), 2);
        n = numel(axs);
        if numel(unique(px)) < n, return; end     % panels already share a column
        [~, ord] = sort(px); axs = axs(ord);
        % Two square panels share a row; every other panel takes a full row.
        sq = arrayfun(@(a) strcmp(a.DataAspectRatioMode, 'manual'), axs);
        rowOf = zeros(n, 1); colOf = ones(n, 1); r = 0; k = 1;
        while k <= n
            r = r + 1; rowOf(k) = r;
            if k < n && sq(k) && sq(k+1), colOf(k+1) = 2; rowOf(k+1) = r; k = k + 2; else, k = k + 1; end
        end
        g = pubfig.new('wide'); t = tiledlayout(g, r, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
        legends = findall(f, 'Type', 'legend'); bars = findall(f, 'Type', 'colorbar');
        for k = 1:n
            a = axs(k); a.Parent = t; a.Layout.Tile = 2 * (rowOf(k) - 1) + colOf(k);
            if nnz(rowOf == rowOf(k)) == 1, a.Layout.TileSpan = [1 2]; end
        end
        for lg = legends', lg.Parent = t; end
        for cb = bars', cb.Parent = t; end
        drawnow; moved = true;
    end
    function layout(f)
        % Canvas follows the content: square for equal-aspect axes, wider for side-by-side panels, taller for stacks.
        axs = findall(f, 'Type', 'axes'); axs = axs(arrayfun(@(a) ~isa(a, 'matlab.graphics.axis.PolarAxes'), axs));
        if isempty(axs), return; end
        drawnow;
        % OuterPosition keeps the grid cell even when equal-aspect axes shrink their plot box.
        pos = cell2mat(arrayfun(@(a) a.OuterPosition(:)', axs, 'UniformOutput', false));
        cols = numel(unique(round(pos(:,1), 1))); rows = numel(unique(round(pos(:,2), 1)));
        mixedHeight = 0; tl = findall(f, 'Type', 'tiledlayout');
        if isscalar(tl) && all(arrayfun(@(a) isequal(a.Parent, tl), axs))
            % Tiles report the plot box, so read the grid from the tile numbers instead.
            tiles = arrayfun(@(a) a.Layout.Tile, axs); gs = tl.GridSize;
            if all(tiles > 0)
                cols = numel(unique(mod(tiles - 1, gs(2)))); rows = numel(unique(floor((tiles - 1) / gs(2))));
                spans = arrayfun(@(a) a.Layout.TileSpan(2), axs);
                if gs(2) > 1 && (any(spans == gs(2)) || all(arrayfun(@(a) strcmp(a.DataAspectRatioMode, 'manual'), axs)))
                    % Mixed rows: full-width panels above or below a pair of square panels.
                    rowIdx = floor((tiles - 1) / gs(2)); h = 0;
                    for rr = unique(rowIdx)'
                        inRow = axs(rowIdx == rr);
                        if numel(inRow) > 1, h = h + 4.4;
                        elseif strcmp(inRow.DataAspectRatioMode, 'manual'), h = h + 5.4;
                        else, h = h + 4.2;
                        end
                    end
                    cols = 1; rows = 0; mixedHeight = h;
                end
            end
        end
        anyEqual = any(arrayfun(@(a) strcmp(a.DataAspectRatioMode, 'manual'), axs));
        equalAspect = numel(axs) == 1 && strcmp(axs(1).DataAspectRatioMode, 'manual');
        if mixedHeight > 0, sz = [6.6 mixedHeight];
        elseif equalAspect, sz = [5.6 5.2];
        elseif cols >= 3, sz = [12 4.4];
        elseif cols == 2, sz = [10 4.6];
        elseif rows >= 3, sz = [6.6, (4.2 + 1.2 * anyEqual) * rows];
        elseif rows == 2, sz = [6.6, 7.6 + 2.0 * anyEqual];
        else, sz = [6.6 4.2];
        end
        % Legends placed outside the axes need extra canvas.
        for lg = findall(f, 'Type', 'legend')'
            loc = lower(lg.Location);
            if contains(loc, 'outside')
                % Outside legends are clipped by the tight export; place them inside where they hide the least data.
                lg.Location = 'best';
            end
        end
        f.Units = 'inches'; f.Position(3:4) = sz;
        % Let MATLAB fit title, tick labels and axis labels inside the canvas.
        hasBar = ~isempty(findall(f, 'Type', 'colorbar'));
        if hasBar && numel(axs) == 1, f.Position(3) = f.Position(3) * 1.12; end
        plain = axs(arrayfun(@(a) isa(a.Parent, 'matlab.ui.Figure'), axs));
        if numel(plain) > 1
            % Plain subplots: give each one a grid cell so 18 pt labels fit inside the canvas.
            px = round(cell2mat(arrayfun(@(a) a.Position(1), plain, 'UniformOutput', false)), 2);
            py = round(cell2mat(arrayfun(@(a) a.Position(2), plain, 'UniformOutput', false)), 2);
            ux = unique(px); uy = sort(unique(py), 'descend');
            for k = 1:numel(plain)
                c = find(ux == px(k), 1); r = find(uy == py(k), 1);
                plain(k).PositionConstraint = 'outerposition';
                plain(k).OuterPosition = [(c-1)/numel(ux), 1 - r/numel(uy), 1/numel(ux), 1/numel(uy)];
            end
        end
        for ax = axs'
            if ~isa(ax.Parent, 'matlab.ui.Figure'), continue; end
            ax.PositionConstraint = 'outerposition';
            if numel(axs) == 1
                % Leave room on the right for a colorbar and its tick labels.
                if hasBar, ax.OuterPosition = [0 0 0.84 1]; else, ax.OuterPosition = [0 0 1 1]; end
            end
        end
        drawnow;
        pubfig.pad(f); drawnow;
        pubfig.dodge(f);
        drawnow;
    end
    function dodge(f)
        % Move each legend to the location that hides the fewest data points; add headroom when every location hides some.
        for lg = findall(f, 'Type', 'legend')'
            ax = lg.Axes; if isempty(ax), continue; end
            best = pubfig.covered(lg, ax); if best == 0, continue; end
            choice = lg.Location; bestCount = best;
            for loc = {'best', 'northwest', 'northeast', 'southwest', 'southeast', 'north', 'south', 'east', 'west'}
                lg.Location = loc{1}; drawnow;
                c = pubfig.covered(lg, ax);
                if c < bestCount, bestCount = c; choice = loc{1}; end
                if c == 0, break; end
            end
            lg.Location = choice;
            if bestCount > 0 && strcmp(ax.YScale, 'linear')
                % Add headroom step by step and try the three upper positions each time.
                yl0 = ax.YLim;
                for step = 1:3
                    ax.YLim = [yl0(1), yl0(2) + 0.35 * step * diff(yl0)];
                    for loc = {'north', 'northwest', 'northeast'}
                        lg.Location = loc{1}; drawnow;
                        if pubfig.covered(lg, ax) == 0, bestCount = 0; break; end
                    end
                    if bestCount == 0, break; end
                end
                if bestCount > 0, ax.YLim = yl0; end
            end
            if bestCount > 0 && pubfig.covered(lg, ax) > 0
                pubfig.legendBelow(lg, ax);
            end
            if pubfig.covered(lg, ax) > 0
                fprintf('PUBFIG NOTE legend of "%s" still covers %d data points\n', pubfig.short(ax.Title.String), pubfig.covered(lg, ax));
            end
        end
    end
    function legendBelow(lg, ax)
        % Place the legend under the axes and give the canvas the extra height it needs.
        if isa(ax.Parent, 'matlab.graphics.layout.TiledChartLayout')
            lg.Location = 'southoutside'; drawnow; return;   % the layout reserves the space itself
        end
        f = ancestor(ax, 'figure'); f.Units = 'inches';
        lg.Units = 'inches'; lh = lg.Position(4); lg.Units = 'normalized';
        gap = 0.15; extra = lh + gap;
        f.Position(4) = f.Position(4) + extra; drawnow;
        frac = extra / f.Position(4);
        ax.Units = 'normalized'; op = ax.OuterPosition;
        ax.OuterPosition = [op(1), op(2) + frac, op(3), op(4) - frac]; drawnow;
        lg.Location = 'none'; lg.Units = 'normalized';
        lg.Position(1) = op(1) + (op(3) - lg.Position(3)) / 2; lg.Position(2) = op(2) + (gap / 2) / f.Position(4); drawnow;
    end
    function tf = anyCovered(f)
        tf = false;
        for lg = findall(f, 'Type', 'legend')'
            ax = lg.Axes; if isempty(ax), continue; end
            if pubfig.covered(lg, ax) > 0, tf = true; return; end
        end
    end
    function pad(f)
        % Markers that sit on the axis frame get a small margin; bars that reach the top get headroom.
        for ax = findall(f, 'Type', 'axes')'
            if isa(ax, 'matlab.graphics.axis.PolarAxes') || ~isempty(findall(ax, 'Type', 'image')), continue; end
            if strcmp(ax.XScale, 'log') || strcmp(ax.YScale, 'log'), continue; end
            try, xl = ruler2num(ax.XAxis.Limits, ax.XAxis); yl = ruler2num(ax.YAxis.Limits, ax.YAxis); catch, continue; end
            if ~isnumeric(xl) || ~isnumeric(yl), continue; end
            xs = []; ys = []; markersOnly = true;
            objs = [findall(ax, 'Type', 'line'); findall(ax, 'Type', 'scatter'); findall(ax, 'Type', 'errorbar')];
            for h = objs'
                try
                    xs = [xs; double(ruler2num(h.XData(:), ax.XAxis))]; ys = [ys; double(ruler2num(h.YData(:), ax.YAxis))]; %#ok<AGROW>
                    if isprop(h, 'LineStyle') && ~strcmp(h.LineStyle, 'none') && numel(h.XData) > 1, markersOnly = false; end
                catch
                end
            end
            bars = findall(ax, 'Type', 'bar');
            for h = bars', try, ys = [ys; double(h.YEndPoints(:))]; catch, end, end %#ok<AGROW>
            xs = xs(isfinite(xs)); ys = ys(isfinite(ys)); tol = 0.02;
            if strcmp(ax.XLimMode, 'auto') && ~isempty(xs) && isempty(bars) && markersOnly
                if min(xs) <= xl(1) + tol * diff(xl) || max(xs) >= xl(2) - tol * diff(xl)
                    ax.XLim = [min(min(xs), xl(1)) - 0.08 * diff(xl), max(max(xs), xl(2)) + 0.08 * diff(xl)];
                end
            end
            if strcmp(ax.YLimMode, 'auto') && ~isempty(ys)
                lo = yl(1); hi = yl(2);
                if max(ys) >= yl(2) - tol * diff(yl), hi = max(max(ys), yl(2)) + 0.08 * diff(yl); end
                if isempty(bars) && min(ys) <= yl(1) + tol * diff(yl), lo = min(min(ys), yl(1)) - 0.08 * diff(yl); end
                if lo ~= yl(1) || hi ~= yl(2), ax.YLim = [lo hi]; end
            end
        end
    end
    function n = covered(lg, ax)
        % Number of plotted points that fall inside the legend box.
        lg.Units = 'normalized'; lp = lg.Position; ax.Units = 'normalized'; ap = ax.Position;
        m = 0.03;   % keep a clear margin between the legend frame and the data
        u = [(lp(1) - ap(1)) / ap(3) - m, (lp(1) + lp(3) - ap(1)) / ap(3) + m];
        v = [(lp(2) - ap(2)) / ap(4) - m, (lp(2) + lp(4) - ap(2)) / ap(4) + m];
        n = 0;
        if u(2) <= m || u(1) >= 1 - m || v(2) <= m || v(1) >= 1 - m, return; end   % legend sits outside the plot box
        try
            xl = ruler2num(ax.XAxis.Limits, ax.XAxis); yl = ruler2num(ax.YAxis.Limits, ax.YAxis);
        catch
            return;
        end
        if ~isnumeric(xl) || ~isnumeric(yl), return; end
        if strcmp(ax.XScale, 'log'), xr = 10.^(log10(xl(1)) + u * diff(log10(xl))); else, xr = xl(1) + u * diff(xl); end
        if strcmp(ax.YScale, 'log'), yr = 10.^(log10(yl(1)) + v * diff(log10(yl))); else, yr = yl(1) + v * diff(yl); end
        for h = findall(ax, '-property', 'XData')'
            if ~isprop(h, 'YData') || isa(h, 'matlab.graphics.chart.primitive.Histogram'), continue; end
            try
                x = double(ruler2num(h.XData(:), ax.XAxis)); y = double(ruler2num(h.YData(:), ax.YAxis));
                if isa(h, 'matlab.graphics.chart.primitive.Bar'), y = double(h.YEndPoints(:)); x = double(ruler2num(h.XEndPoints(:), ax.XAxis)); end
            catch
                continue;   % otherwise non-numeric data
            end
            if numel(x) ~= numel(y), continue; end
            if (isa(h, 'matlab.graphics.chart.primitive.Line') || isa(h, 'matlab.graphics.chart.primitive.ErrorBar') || isa(h, 'matlab.graphics.chart.primitive.Stair')) && ~strcmp(h.LineStyle, 'none') && numel(x) > 1
                % Sample along the segments so a line passing under the legend counts as covered.
                ok = isfinite(x) & isfinite(y); x = x(ok); y = y(ok);
                if numel(x) > 1
                    t = linspace(0, 1, 40)'; xs = []; ys = [];
                    for q = 1:numel(x)-1, xs = [xs; x(q) + t*(x(q+1)-x(q))]; ys = [ys; y(q) + t*(y(q+1)-y(q))]; end %#ok<AGROW>
                    x = xs; y = ys;
                end
            end
            if isa(h, 'matlab.graphics.chart.primitive.ErrorBar')
                % The whiskers hide data too: sample along each vertical bar.
                try
                    x0 = double(ruler2num(h.XData(:), ax.XAxis)); y0 = double(ruler2num(h.YData(:), ax.YAxis));
                    nd = double(h.YNegativeDelta(:)); pd = double(h.YPositiveDelta(:));
                    if isempty(nd), nd = zeros(size(y0)); end
                    if isempty(pd), pd = zeros(size(y0)); end
                    ok = isfinite(x0) & isfinite(y0) & isfinite(nd) & isfinite(pd); x0 = x0(ok); y0 = y0(ok); nd = nd(ok); pd = pd(ok);
                    t = linspace(0, 1, 20)';
                    for q = 1:numel(x0), x = [x; repmat(x0(q), 20, 1)]; y = [y; y0(q) - nd(q) + t * (nd(q) + pd(q))]; end %#ok<AGROW>
                catch
                end
            end
            if isa(h, 'matlab.graphics.chart.primitive.Bar') || isa(h, 'matlab.graphics.chart.primitive.Stem')
                inside = x >= xr(1) & x <= xr(2) & y >= yr(1);   % bars and stems fill down to the axis
            else
                inside = x >= xr(1) & x <= xr(2) & y >= yr(1) & y <= yr(2);
            end
            n = n + nnz(inside);
        end
        % Reference lines from xline and yline run through the legend as well.
        for h = findall(ax, 'Type', 'constantline')'
            try
                v = double(h.Value);
                if strcmpi(h.InterceptAxis, 'x') && any(v >= xr(1) & v <= xr(2)), n = n + 5; end
                if strcmpi(h.InterceptAxis, 'y') && any(v >= yr(1) & v <= yr(2)), n = n + 5; end
            catch
            end
        end
    end
    function floor(f)
        % Font, line and marker floors; applied before layout so every measurement sees the final sizes.
        for h = findall(f, '-property', 'FontSize')'
            if h.FontSize < 18, h.FontSize = 18; end
        end
        for h = findall(f, 'Type', 'line')'
            if ~strcmp(h.LineStyle, 'none') && h.LineWidth < 1.5, h.LineWidth = 1.5; end
            if ~strcmp(h.Marker, 'none') && h.MarkerSize < 6, h.MarkerSize = 6; end
        end
        for h = findall(f, 'Type', 'scatter')', h.SizeData = max(h.SizeData, 24); end
        for h = findall(f, 'Type', 'stair')', if h.LineWidth < 1.5, h.LineWidth = 1.5; end, end
        for h = findall(f, 'Type', 'stem')', if h.LineWidth < 1.2, h.LineWidth = 1.2; end, end
        for h = findall(f, 'Type', 'errorbar')', if h.LineWidth < 1.5, h.LineWidth = 1.5; end, end
        drawnow;
    end
    function problems = check(f, name)
        problems = {};
        pubfig.floor(f);
        boxes = {}; labels = {};
        for ax = findall(f, 'Type', 'axes')'
            ax.Units = 'normalized'; ap = ax.Position;
            for tx = [ax.Title ax.XLabel ax.YLabel]
                if isempty(tx.String), continue; end
                pubfig.wrap(tx, ax, ap);
            end
        end
        drawnow;
        for ax = findall(f, 'Type', 'axes')'
            ap = ax.Position; items = [ax.Title ax.XLabel ax.YLabel];
            texts = items; seen = items;
            for tx = findall(ax, 'Type', 'text')'
                if ~any(tx == seen), texts(end+1) = tx; seen(end+1) = tx; end %#ok<AGROW>
            end
            for tx = texts
                if isempty(tx.String), continue; end
                b = pubfig.box(tx, ap); if isempty(b), continue; end
                boxes{end+1} = b; labels{end+1} = pubfig.short(tx.String); %#ok<AGROW>
            end
        end
        for lg = findall(f, 'Type', 'legend')'
            lg.Units = 'normalized'; boxes{end+1} = lg.Position; labels{end+1} = 'legend'; %#ok<AGROW>
        end
        equalAspect = any(arrayfun(@(a) strcmp(a.DataAspectRatioMode, 'manual'), findall(f, 'Type', 'axes')));
        for k = 1:numel(boxes)
            b = boxes{k};
            if ~equalAspect && (b(1) < -0.01 || b(2) < -0.01 || b(1)+b(3) > 1.01 || b(2)+b(4) > 1.01)
                problems{end+1} = sprintf('%s: "%s" leaves the canvas', name, labels{k}); %#ok<AGROW>
            end
            for j = k+1:numel(boxes)
                c = boxes{j};
                ox = min(b(1)+b(3), c(1)+c(3)) - max(b(1), c(1)); oy = min(b(2)+b(4), c(2)+c(4)) - max(b(2), c(2));
                if ox > 0.005 && oy > 0.005
                    problems{end+1} = sprintf('%s: "%s" overlaps "%s"', name, labels{k}, labels{j}); %#ok<AGROW>
                end
            end
        end
    end
    function wrap(tx, ax, ap)
        % Break a title or label into more lines until it fits the canvas width.
        if strcmp(ax.DataAspectRatioMode, 'manual')
            % Equal-aspect boxes are not measurable this way: split a long title in two by word count.
            if isequal(tx, ax.Title) && ischar(tx.String) && numel(tx.String) > 34
                words = strsplit(tx.String, ' '); half = max(1, round(numel(words)/2));
                tx.String = {strjoin(words(1:half), ' '), strjoin(words(half+1:end), ' ')}; drawnow;
            end
            return;
        end
        for attempt = 1:3
            b = pubfig.box(tx, ap);
            if isempty(b), return; end
            vertical = abs(tx.Rotation) > 45;
            isTitle = isequal(tx, ax.Title);
            limit = min(0.9, max(0.5, 1.15 * ap(3)));   % a title wider than this collides with the rotated y label
            if vertical
                fits = b(2) >= -0.01 && b(2)+b(4) <= 1.01 && (~isTitle || b(4) <= 0.98);
            else
                fits = b(1) >= -0.01 && b(1)+b(3) <= 1.01 && (~isTitle || b(3) <= limit);
            end
            if fits, return; end
            s = tx.String; if ischar(s), s = {s}; end; s = cellstr(s);
            [~, i] = max(cellfun(@length, s)); words = strsplit(s{i}, ' ');
            if numel(words) < 2, return; end
            half = max(1, round(numel(words)/2));
            s = [s(1:i-1); {strjoin(words(1:half), ' ')}; {strjoin(words(half+1:end), ' ')}; s(i+1:end)];
            tx.String = s; drawnow;
        end
        if strcmp(ax.Visible, 'on'), end
    end
    function b = box(tx, ap)
        try
            old = tx.Units; tx.Units = 'normalized'; e = tx.Extent; tx.Units = old;
            b = [ap(1)+e(1)*ap(3), ap(2)+e(2)*ap(4), e(3)*ap(3), e(4)*ap(4)];
        catch
            b = [];
        end
    end
    function s = short(str)
        if iscell(str) || isstring(str), str = strjoin(cellstr(str), ' / '); end
        s = char(str); if numel(s) > 40, s = [s(1:37) '...']; end
    end
    function record(problems)
        all = getappdata(groot, 'pubfigProblems'); if isempty(all), all = {}; end
        setappdata(groot, 'pubfigProblems', [all problems]);
    end
    function reset
        setappdata(groot, 'pubfigProblems', {});
    end
    function report
        all = getappdata(groot, 'pubfigProblems'); if isempty(all), all = {}; end
        fprintf('PUBFIG SUMMARY: %d problems\n', numel(all));
        for k = 1:numel(all), fprintf('  %s\n', all{k}); end
    end
end
end
