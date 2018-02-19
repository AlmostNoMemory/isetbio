function hFig = visualizeGrid(obj, varargin)
% Visualize different aspects of the hexagonal cone mosaic
%
% Syntax:
%   hFig = coneMosaicHex.visualizeGrid(varargin);
%
% Description:
%   Visualize the eye movements on top of the cone mosaic.  There are
%   many options for how to visualize (see below).  This routine is
%   typically used to understand what happens to the fixational eye
%   movements with respect to the cone mosaic.
%
% Inputs:
%   N/A
%
% Outputs:
%   hFig - Figure handle
%
% Optional key/value pairs:
%
%   axesHandle         - Axes handle to draw on (default is empty)
%   generateNewFigure  - logical (false)
%   panelPosition      - [1 1]
%
%   visualizedConeAperture -   'lightCollectingArea'*, 'geometricArea', 'both'
%   showCorrespondingRectangularMosaicInstead - False
%   overlayNullSensors     - logical (false)
%   labelConeTypes         - logical (true)
%   apertureShape          - 'hexagons'*, 'disks'
%
%   overlayEMpath Microns  - a single EM path (specified in microns) that can be overlayed on top of the mosaic
%   overlayHexMesh         - logical (false)
%   overlayConeDensityContour   - 'none'
%   coneDensityContourLevelStep - 5000
%
% NPC, ISETBIO TEAM, 2015
%
% See also: coneMosaicHex

% Examples:
%{
resamplingFactor = 5; eccBasedConeDensity = false;
customLamda = [];     customInnerSegmentDiameter = [];
cm = coneMosaicHex(resamplingFactor, ...
        'fovDegs', 0.3, ...
        'eccBasedConeDensity', eccBasedConeDensity, ... 
        'customLambda', customLamda, ...
        'customInnerSegmentDiameter', customInnerSegmentDiameter ...
    );

fixEMobj = fixationalEM();
fixEMobj.computeForConeMosaic(cm, 200, 'nTrials', 1, 'rSeed', 1);
h = cm.visualizeGrid(...
    'axes handle', [], ...
    'overlay EM path microns', squeeze(fixEMobj.emPosMicrons(1,:,:)), ...
    'overlay null sensors', false, ...
    'aperture shape', 'disks', ...
    'visualized cone aperture', 'lightCollectingArea', ...
    'overlay cone density contour','theoretical', ...
    'label cone types', true, ...
    'generate new figure',true);
%}

%% parse input
p = inputParser;

varargin = ieParamFormat(varargin);

% Window options
p.addParameter('generatenewfigure', false, @islogical);
p.addParameter('panelposition', [1 1]);
p.addParameter('axeshandle', []);

% Mosaic options
p.addParameter('labelconetypes', true, @islogical);
p.addParameter('showcorrespondingrectangularmosaicinstead', false, @islogical);
p.addParameter('visualizedconeaperture', 'lightCollectingArea', @(x)ismember(x, {'lightCollectingArea', 'geometricArea', 'both'}));
p.addParameter('apertureshape', 'hexagons', @(x)ismember(x, {'hexagons', 'disks'}));

% Overlay options
p.addParameter('overlaynullsensors', false, @islogical);
p.addParameter('overlayempathmicrons', [], @(x)(isnumeric(x) && ((isempty(x)) || (ndims(x)==2))));
p.addParameter('overlayhexmesh', false, @islogical);
p.addParameter('overlayconedensitycontour', 'none', @(x)ismember(x, {'none', 'theoretical', 'measured', 'theoretical_and_measured'}));
p.addParameter('conedensitycontourlevels', [100:20:250]*1000, @isnumeric);
p.addParameter('overlaycontourlabels', false, @islogical);
p.addParameter('backgroundcolor', [0.75 0.75 0.75]);
p.addParameter('foregroundcolor', [0 0 0]);

p.parse(varargin{:});

generateNewFigure      = p.Results.generatenewfigure;
panelPosition          = p.Results.panelposition;
backgroundColor           = p.Results.backgroundcolor;
foregroundColor           = p.Results.foregroundcolor;

labelConeTypes           = p.Results.labelconetypes;
showCorrespondingRectangularMosaicInstead = p.Results.showcorrespondingrectangularmosaicinstead;
visualizedConeAperture   = p.Results.visualizedconeaperture;
apertureShape            = p.Results.apertureshape;

overlayNullSensors        = p.Results.overlaynullsensors;
overlaidEMpathMicrons     = p.Results.overlayempathmicrons;
overlayHexMesh            = p.Results.overlayhexmesh;
overlayConeDensityContour = p.Results.overlayconedensitycontour;
coneDensityContourLevels  = p.Results.conedensitycontourlevels;
if (p.Results.overlaycontourlabels)
    overlaycontourlabels = 'on';
else
    overlaycontourlabels = 'off';
end

%% Set up cone coordinates and outline
sampledHexMosaicXaxis = obj.patternSupport(1,:,1) + obj.center(1);
sampledHexMosaicYaxis = obj.patternSupport(:,1,2) + obj.center(2);

% Choose the radius of the aperture obj.pigment.pdWidth or obj.pigment.width
if (strcmp(visualizedConeAperture, 'lightCollectingArea'))
    % Note that pigment.pdWidth defines the size of a square collective
    % aperture. Here we compute the equivalent circular aperture
    dxInner = diameterForCircularApertureFromWidthForSquareAperture(obj.pigment.pdWidth);
    dxOuter = [];
elseif (strcmp(visualizedConeAperture, 'geometricArea'))
    dxOuter = diameterForCircularApertureFromWidthForSquareAperture(obj.pigment.width);
    dxInner = [];
elseif (strcmp(visualizedConeAperture, 'both'))
    dxInner = diameterForCircularApertureFromWidthForSquareAperture(obj.pigment.pdWidth);
    dxOuter = diameterForCircularApertureFromWidthForSquareAperture(obj.pigment.width);
end

if (showCorrespondingRectangularMosaicInstead)
    titleString = sprintf('<RECT grid> cones: %d x %d (%d total)', ...
        size(obj.patternOriginatingRectGrid,2), size(obj.patternOriginatingRectGrid,1), numel(obj.patternOriginatingRectGrid));
else
    titleString = sprintf('cones: %d (LMS), %d (LMSK), resampleF: %d, aperture: %s', ...
        numel(find(obj.pattern > 1)), numel(obj.pattern), obj.resamplingFactor, visualizedConeAperture);
end

%% The outline of pixels in the original rect grid
pixelOutline.x = [0 0 1 1 0]*obj.patternSampleSize(1);
pixelOutline.y = [0 1 1 0 0]*obj.patternSampleSize(1);

if strcmp(apertureShape, 'hexagons')
    iTheta = (0:60:360)/180*pi;
else
    iTheta = (0:10:360)/180*pi;
end
if (~isempty(dxOuter))  
    outerApertureOutline.x = dxOuter/2.0 * cos(iTheta);
    outerApertureOutline.y = dxOuter/2.0 * sin(iTheta);
else
    outerApertureOutline = [];
end
if (~isempty(dxInner))  
    innerApertureOutline.x = dxInner/2.0 * cos(iTheta);
    innerApertureOutline.y = dxInner/2.0 * sin(iTheta);
else
    innerApertureOutline = [];
end

rectCoords = obj.coneLocsOriginatingRectGrid;
hexCoords = obj.coneLocsHexGrid;

%% Set up figure
axesHandle = p.Results.axeshandle;
if (isempty(axesHandle))
    if (generateNewFigure)
        hFig = figure(round(rand()*100000));
        if (isempty(panelPosition))
            figPosition = [rand()*2000 rand()*1000 750 750];
        else
            figPosition = [(panelPosition(1)-1)*980 (panelPosition(2)-1)*700 750 750];
        end
    else
        % We want to use the coneMosaic window 
        if (isempty(panelPosition))
            hFig = figure(1);
            figPosition = [rand()*2000 rand()*1000 750 750];
        else
            hFig = figure(panelPosition(1)*10+panelPosition(2));
            figPosition = [(panelPosition(1)-1)*980 (panelPosition(2)-1)*700  750 750];
        end
    end
    cla;
    set(hFig, 'Position', figPosition, 'Color', backgroundColor); % , 'MenuBar', 'none', 'NumberTitle', 'off');
    set(hFig, 'Name', titleString);
    subplot('Position', [0.1 0.04 0.89 0.92]);
    axesHandle = gca;
else
    hFig = get(gca,'Parent');
end


hold(axesHandle, 'on');

%% Do the display

% Odd that this is here and then again later.  I am trying to delete.
% switch overlayConeDensityContour
%     case 'measured'
%         [densityMapMeasured, densityMapSupportX, densityMapSupportY] = ...
%             obj.computeDensityMap('from mosaic');
%     case 'theoretical'
%         [densityMapTheoretical, densityMapSupportX, densityMapSupportY] =...
%             obj.computeDensityMap('from model');
%     case 'theoretical_and_measured'
%         [densityMapMeasured, densityMapSupportX, densityMapSupportY] = ...
%             obj.computeDensityMap('from mosaic');
%         [densityMapTheoretical, densityMapSupportX, densityMapSupportY] = ...
%             obj.computeDensityMap('from model');
%     case 'none'
%     otherwise
%         error('coneMosaicHex.visualizeGrid: ''coneDensityContourOverlay'' must be set to one of the following: ''measured'', ''theoretical'', ''none''. ');
% end

if (overlayHexMesh)
        % Superimpose hex mesh showing the locations of the perfect hex grid
        meshFaceColor = [0.8 0.8 0.8]; meshEdgeColor = [0.5 0.5 0.5]; meshFaceAlpha = 0.0; meshEdgeAlpha = 0.5; lineStyle = '-';
        coneMosaicHex.renderHexMesh(axesHandle, hexCoords(:,1), hexCoords(:,2), meshEdgeColor, meshFaceColor, meshFaceAlpha, meshEdgeAlpha, lineStyle);
end
    
if (~showCorrespondingRectangularMosaicInstead)
    lineStyle = '-';
    lineWidth = 0.5;
    if (overlayNullSensors)
        idx = find(obj.pattern==1);
        [iRows,iCols] = ind2sub(size(obj.pattern), idx);
        edgeColor = [0.4 0.4 0.4]; faceColor = 'none';
        coneMosaicHex.renderPatchArray(axesHandle, pixelOutline, sampledHexMosaicXaxis(iCols), sampledHexMosaicYaxis(iRows), edgeColor, faceColor, lineStyle, lineWidth);
    end
    
    % L-cones
    lineWidth = 0.2;
    idx = find(obj.pattern == 2);
    [iRows,iCols] = ind2sub(size(obj.pattern), idx);
    edgeColor = 'none'; % [1 0 0]; 
    if (labelConeTypes)
        faceColorInner = [1 0 0];
        faceColorOuter = [1 0 0];
    else
        edgeColor = [0 0 0]; 
        faceColorInner = 0.3*[1 1 1];
        faceColorOuter = 0.3*[1 1 1];
    end
    if (~isempty(outerApertureOutline))
        coneMosaicHex.renderPatchArray(axesHandle, outerApertureOutline, sampledHexMosaicXaxis(iCols), sampledHexMosaicYaxis(iRows), edgeColor, faceColorOuter, lineStyle, lineWidth);
    end
    if (~isempty(innerApertureOutline))
        coneMosaicHex.renderPatchArray(axesHandle, innerApertureOutline, sampledHexMosaicXaxis(iCols), sampledHexMosaicYaxis(iRows), edgeColor, faceColorInner, lineStyle, lineWidth);
    end
    
    % M-cones
    idx = find(obj.pattern == 3);
    [iRows,iCols] = ind2sub(size(obj.pattern), idx);
    edgeColor = 'none';% = [0 0.7 0]; 
    if (labelConeTypes)
        if (mean(backgroundColor) < 0.5)
            faceColorInner = [0 1 0];
            faceColorOuter = [0.2 1 0.2];
        else
            faceColorInner = [0 1 0];
            faceColorOuter = [0 1 0];
        end
    else
        edgeColor = [0 0 0]; 
        faceColorInner = 0.3*[1 1 1];
        faceColorOuter = 0.3*[1 1 1];
    end
    
    if (~isempty(outerApertureOutline))
        coneMosaicHex.renderPatchArray(axesHandle, outerApertureOutline, ...
            sampledHexMosaicXaxis(iCols), sampledHexMosaicYaxis(iRows), ...
            edgeColor, faceColorOuter, lineStyle, lineWidth);
    end
    if (~isempty(innerApertureOutline))
        coneMosaicHex.renderPatchArray(axesHandle, innerApertureOutline, ...
            sampledHexMosaicXaxis(iCols), sampledHexMosaicYaxis(iRows), ...
            edgeColor, faceColorInner, lineStyle, lineWidth);
    end
    
    % S-cones
    idx = find(obj.pattern == 4);
    [iRows,iCols] = ind2sub(size(obj.pattern), idx);
    edgeColor = 'none';% = [0 0 1]; 
    if (labelConeTypes)
        if (mean(backgroundColor) < 0.5)
            faceColorInner = [0 .4 1];
            faceColorOuter = [0.1 0.4 1];
        else
            faceColorInner = [0 0 1];
            faceColorOuter = [0 0 1];
        end
    else
        edgeColor = [0 0 0]; 
        faceColorInner = 0.3*[1 1 1];
        faceColorOuter = 0.3*[1 1 1];
    end
    
    if (~isempty(outerApertureOutline))
        coneMosaicHex.renderPatchArray(axesHandle, outerApertureOutline, sampledHexMosaicXaxis(iCols), sampledHexMosaicYaxis(iRows), edgeColor, faceColorOuter, lineStyle, lineWidth);
    end
    if (~isempty(innerApertureOutline))
        coneMosaicHex.renderPatchArray(axesHandle, innerApertureOutline, sampledHexMosaicXaxis(iCols), sampledHexMosaicYaxis(iRows), edgeColor, faceColorInner, lineStyle, lineWidth);
    end
    
else
    lineWidth = 0.5;
    % Show the corresponding rectangular mosaic
    % The original rect sensors
    idx = find(obj.patternOriginatingRectGrid==2);
    %[iRows,iCols] = ind2sub(size(obj.patternOriginatingRectGrid), idx);
    edgeColor = [0.3 0.3 0.3]; faceColor = [1.0 0.7 0.7]; lineStyle = '-';
    coneMosaicHex.renderPatchArray(axesHandle, pixelOutline, rectCoords(idx,1), rectCoords(idx,2), edgeColor, faceColor, lineStyle, lineWidth);
    
    idx = find(obj.patternOriginatingRectGrid==3);
    %[iRows,iCols] = ind2sub(size(obj.patternOriginatingRectGrid), idx);
    edgeColor = [0.3 0.3 0.3]; faceColor = [0.7 1.0 0.7];
    coneMosaicHex.renderPatchArray(axesHandle, pixelOutline, rectCoords(idx,1), rectCoords(idx,2), edgeColor, faceColor, lineStyle, lineWidth);
    
    idx = find(obj.patternOriginatingRectGrid==4);
    %[iRows,iCols] = ind2sub(size(obj.patternOriginatingRectGrid), idx);
    edgeColor = [0.3 0.3 0.3]; faceColor = [0.7 0.7 1.0];
    coneMosaicHex.renderPatchArray(axesHandle, pixelOutline, rectCoords(idx,1), rectCoords(idx,2), edgeColor, faceColor, lineStyle, lineWidth);
end


contourLevels = coneDensityContourLevels;
contourLabelSpacing = 4000;

plotContoursOverHalfField = false;
    
switch overlayConeDensityContour
    case 'measured'
        [densityMapMeasured, densityMapSupportX, densityMapSupportY] = obj.computeDensityMap('from mosaic');
        if (plotContoursOverHalfField)
            idx = find(~((densityMapSupportX >= 0) & (densityMapSupportY >= 0)));
            densityMapMeasured(idx) = NaN;
        end
        [cH, hH] = contour(axesHandle, densityMapSupportX, densityMapSupportY, densityMapMeasured, contourLevels, 'LineColor', 'r', 'LineWidth', 2.0, ...
            'ShowText', overlaycontourlabels, 'LabelSpacing', contourLabelSpacing);
        clabel(cH,hH,'FontWeight','bold', 'FontSize', 16, 'Color', [1 0 0], 'BackgroundColor', [1 1 1]);
        set(gca, 'CLim', [10000 250000]);
    
    case 'theoretical'
        [densityMapTheoretical, densityMapSupportX, densityMapSupportY] = obj.computeDensityMap('from model');
        if (plotContoursOverHalfField)
            idx = find(~((densityMapSupportX >= 0) & (densityMapSupportY >= 0)));
            densityMapTheoretical(idx) = NaN;
        end
        
        if (p.Results.overlaycontourlabels)
            [cH, hH] = contour(axesHandle, densityMapSupportX, densityMapSupportY, densityMapTheoretical, contourLevels, 'LineColor', [0.0 1.0 0.3], 'LineWidth', 3.0, ...
            'ShowText', overlaycontourlabels, 'LabelSpacing', contourLabelSpacing);
            clabel(cH,hH,'FontWeight','bold', 'FontSize', 16, 'Color', [0 0 1], 'BackgroundColor', [1 1 1]);
        else
            contour(axesHandle, densityMapSupportX, densityMapSupportY, densityMapTheoretical, contourLevels, 'LineColor', [0.0 1.0 0.3], 'LineWidth', 3.0);
            %clabel(cH,hH,'FontWeight','bold', 'FontSize', 1, 'Color', 'none', 'BackgroundColor', 'none');
        end
        set(gca, 'CLim', [10000 250000]);
        
    case 'theoretical_and_measured'
        [densityMapMeasured, densityMapSupportX, densityMapSupportY] = obj.computeDensityMap('from mosaic');
        [densityMapTheoretical, densityMapSupportX, densityMapSupportY] = obj.computeDensityMap('from model');
        if (plotContoursOverHalfField)
            idx = find(~((densityMapSupportX >= 0) & (densityMapSupportY >= 0)));
            densityMapMeasured(idx) = NaN;
        end
        
        if (p.Results.overlaycontourlabels)
            [cH, hH] = contour(axesHandle, densityMapSupportX, densityMapSupportY, densityMapMeasured, contourLevels, 'LineColor', [1 0.0 0.0], 'LineWidth', 3.0, ...
                'ShowText', overlaycontourlabels, 'LabelSpacing', contourLabelSpacing);
            clabel(cH,hH,'FontWeight','bold', 'FontSize', 16, 'Color', [1 0 0], 'BackgroundColor', 'none');
        else
            contour(axesHandle, densityMapSupportX, densityMapSupportY, densityMapMeasured, contourLevels, 'LineColor', [1 0.0 0.0], 'LineWidth', 3.0);
        end
        if (plotContoursOverHalfField)
            idx = find(~((densityMapSupportX >= 0) & (densityMapSupportY >= 0)));
            densityMapTheoretical(idx) = NaN;
        end
        [cH, hH] = contour(axesHandle, densityMapSupportX, densityMapSupportY, densityMapTheoretical, contourLevels, 'LineColor', [0.0 1.0 0.3], 'LineWidth', 3.0, ...
            'ShowText', 'on', 'LabelSpacing', contourLabelSpacing);
        clabel(cH,hH,'FontWeight','bold', 'FontSize', 16, 'Color', [0 0 1], 'BackgroundColor', [1 1 1]);
        set(gca, 'CLim', [10000 250000]);
end

set(gca, 'Color', backgroundColor, 'XColor', foregroundColor, 'YColor', foregroundColor);

if (~isempty(overlaidEMpathMicrons))
    color = 'k';
    if (~labelConeTypes)
        color = 'r';
    end
    [m,n] = size(overlaidEMpathMicrons);
    if (m == 2) && (n==1) 
        plot(overlaidEMpathMicrons(1,:)*1e-6, overlaidEMpathMicrons(2, :)*1e-6, 'k.-', 'Color', color, 'LineWidth', 1.5);
    else
        plot(overlaidEMpathMicrons(:,1)*1e-6, overlaidEMpathMicrons(:,2)*1e-6, 'k.-', 'Color', color, 'LineWidth', 1.5);
    end
end 

%% Arrange axis and fonts

hold(axesHandle, 'off')
axis(axesHandle, 'xy'); axis(axesHandle, 'equal'); 

if (isempty(p.Results.axeshandle))
    if (max(obj.fov) < 1.0)
        tickInc = 0.1;
    elseif (max(obj.fov) < 4.0)
        tickInc = 0.25;
    else
        tickInc = 1;
    end
    
    xTicksDegs = (-20:tickInc:20);
    yTicksDegs = xTicksDegs;
    xTicksMeters = xTicksDegs * obj.micronsPerDegree * 1e-6;
    yTicksMeters = xTicksMeters;
    xTickLabels = sprintf('%02.2f\n', xTicksDegs);
    yTickLabels = sprintf('%02.2f\n', yTicksDegs);
    set(axesHandle, 'XTick', xTicksMeters, 'YTick', yTicksMeters, 'XTickLabel', xTickLabels, 'YTickLabel', yTickLabels);
    set(axesHandle, 'FontSize', 18, 'LineWidth', 1.0);
    box(axesHandle, 'on'); grid(axesHandle, 'off');
    %title(axesHandle, sprintf('%2.0f microns', obj.width*1e6), 'FontSize', 18, 'Color', foregroundColor);
    set(axesHandle, 'XLim', [sampledHexMosaicXaxis(1)-1.5*1e-6 sampledHexMosaicXaxis(end)+1.5*1e-6]);
    set(axesHandle, 'YLim', [sampledHexMosaicYaxis(1)-1.5*1e-6 sampledHexMosaicYaxis(end)+1.5*1e-6]);
    
    ylabel('space (degs)');
    drawnow;
end



end