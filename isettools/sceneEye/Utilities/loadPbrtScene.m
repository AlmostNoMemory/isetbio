function [thisR, sceneUnits, workingDir, origPath] = ...
    loadPbrtScene(pbrtFile, se_p, varargin)
% Setup a PBRT scene given it's name or file location. 
%
% Brief description
%
%   1. Check if we're given a pbrt file or a scene name.
%       a) If a pbrt file, read it, and return a thisR
%       b) If a scene name, download it from the RDT, read it, and return a
%          thisR.
%   2. Set up a working folder derived from the scene name. Copy all
%       necessary files over to the newly created working directory.
%   3. Apply any adjustable parameters given by the user to the thisR,
%       e.g. moving a planar target a certain distance away.
%
% TODO: I'd like to keep splitting up the above steps into more functions
% to neaten things up.
%
% Syntax:
%   [thisR sceneUnits] = selectPbrtScene(sceneName, varargin)
%
% Description:
%    The user can call sceneEye with the name of a scene to automatically
%    load it. To remove bloat from the actual sceneEye class, we will do
%    that parsing/selection in this function instead.
%
% Inputs:
%    sceneName - either a scene name like "slantedBar" or an actual pbrt
%                filepath like ("xxx.pbrt")
%    se_p - inputParser from sceneEye needs to be passed in so we can find
%                  certain parameters (e.g. planeDistance) when setting up
%                  the scene.
%    varargin  - An optional length of key/value pairs describing the scene
%
% Outputs:
%    thisR  - thisR of selected scene after adjustment parameters are
%              applied.
%    sceneUnits - some scenes are in meters and some are in millimeters.
%                 There is a flag in the sceneEye class to specify this and
%                 render appropriately.
%    workingDir - a created working directory derived from the scene name.
%    origPath - the original path to the pbrt file 
%
% History:
%    5/25/18  TL   Created
%
% TODO:
%    - List the availble scenes
%
% See also
% 

% Examples:
%{
  SE = sceneEye('texturedPlane');   % Create a sceneEye object
  oi = SE.render;                   % Might work
  ieAddObject(oi); oiWindow;
%}
%% Parse inputs
p = inputParser;
p.addRequired('pbrtFile', @ischar);
p.parse(pbrtFile, varargin{:});

%% Check if we've been given a sceneName or a pbrt file.
[~, sceneName, ext] = fileparts(pbrtFile);
if(isempty(ext))
    % scene name
    sceneNameFlag = true;
else
    % pbrt file
    sceneNameFlag = false;
    scenePath = pbrtFile;
end

%% Load the scene

if(sceneNameFlag)
    % The user has given us a scene name and not a full pbrt
    % file. Let's find or download the right file.
    
    switch sceneName
        
        case('snellenSingle')
            
            scenePath = fullfile(piRootPath, 'data', ...
                'V3','snellenSingle', 'snellen_single.pbrt');
            sceneUnits = 'm';
            
            % Download from RDT
            if(~exist(scenePath,'file'))
                piPBRTFetch('snellenSingle','deletezip',true,...
                    'pbrtversion',3,...
                    'destination folder',fullfile(piRootPath,'data','V3'));
                % Check if file exists
                if(~exist(scenePath,'file'))
                    error('Something went wrong when downloading the scene.')
                else
                    % Success!
                    fprintf('PBRT scene downloaded! File is located at: %s \n',scenePath);
                end
                
            else
                fprintf('Scene already exists in data folder. Skipping download.\n');
            end
            
            
        case ('snellenAtDepth')
            
            scenePath = fullfile(piRootPath,'data','V3','snellenAtDepth','snellen.pbrt');
            sceneUnits = 'm';
            
             % Download from RDT
            if(~exist(scenePath,'file'))
                piPBRTFetch('snellenAtDepth','deletezip',true,...
                    'pbrtversion',3,...
                    'destination folder',fullfile(piRootPath,'data','V3'));
                % Check if file exists
                if(~exist(scenePath,'file'))
                    error('Something went wrong when downloading the scene.')
                else
                    % Success!
                    fprintf('PBRT scene downloaded! File is located at: %s \n',scenePath);
                end
                
            else
                fprintf('Scene already exists in data folder. Skipping download.\n');
            end
            
            
        case ('blackBackdrop')
            
            scenePath = fullfile(piRootPath,'data','V3','blackBackdrop','blackBackdrop.pbrt');
            sceneUnits = 'm';
            
        case ('blankScene')
            
            scenePath = fullfile(piRootPath,'data','V3','blankScene','blankScene.pbrt');
            sceneUnits = 'm';
            
        case('numbersAtDepth')
            
            scenePath = fullfile(piRootPath, 'data', ...
                'V3','NumbersAtDepth', 'numbersAtDepth.pbrt');
            sceneUnits = 'm';
            
            % Download from RDT
            if(~exist(scenePath,'file'))
                piPBRTFetch('NumbersAtDepth','deletezip',true,...
                    'pbrtversion',3,...
                    'destination folder',fullfile(piRootPath,'data','V3'));
                % Check if file exists
                if(~exist(scenePath,'file'))
                    error('Something went wrong when downloading the scene.')
                else
                    % Success!
                    fprintf('PBRT scene downloaded! File is located at: %s \n',scenePath);
                end
                
            else
                fprintf('Scene already exists in data folder. Skipping download.\n');
            end
            
        case('slantedBar')
            scenePath = fullfile(piRootPath, 'data', ...
                'V3','SlantedBar', 'slantedBar.pbrt');
            sceneUnits = 'm';
            
        case('chessSet')

            scenePath = fullfile(piRootPath,'data',...
                'V3','ChessSet','chessSet.pbrt');
            sceneUnits = 'm';
            
            % Download from RDT
            if(~exist(scenePath,'file'))
                piPBRTFetch('ChessSet','deletezip',true,...                    
                    'pbrtversion',3,...
                    'destination folder',fullfile(piRootPath,'data','V3'));
                % Check if file exists
                if(~exist(scenePath,'file'))
                    error('Something went wrong when downloading the scene.')
                else
                    % Success!
                    fprintf('PBRT scene downloaded! File is located at: %s \n',scenePath);
                end

            else
                fprintf('Scene already exists in data folder. Skipping download.\n');
            end
            
            
        case('chessSetScaled')
            
            scenePath = fullfile(piRootPath,'data','V3',...
                'ChessSetScaled','chessSetScaled.pbrt');
            sceneUnits = 'm';
            
            % Download from RDT
            if(~exist(scenePath,'file'))
                piPBRTFetch('ChessSetScaled','deletezip',true,...                    
                    'pbrtversion',3,...
                    'destination folder',fullfile(piRootPath,'data','V3'));
                % Check if file exists
                if(~exist(scenePath,'file'))
                    error('Something went wrong when downloading the scene.')
                else
                    % Success!
                    fprintf('PBRT scene downloaded! File is located at: %s \n',scenePath);
                end

            else
                fprintf('Scene already exists in data folder. Skipping download.\n');
            end

            
        case('texturedPlane')
            scenePath = fullfile(piRootPath, 'data', ...
                'V3','texturedPlane', 'texturedPlane.pbrt');
            sceneUnits = 'm';
            
        case('pointSource')
            scenePath = fullfile(piRootPath,'data',...
                'SimplePoint','simplePointV3.pbrt');
            sceneUnits = 'm';
        
        case('slantedBarAdjustable')
            % A variation of slantedBar where the black and white planes
            % are adjustable to different depths.
            scenePath = fullfile(piRootPath,'data',...
                'V3','slantedBarAdjustableDepth',...
                'slantedBarWhiteFront.pbrt');
            sceneUnits = 'm';
            
        case('slantedBarTexture')
            % A variation of slantedBar where the black and white planes
            % are adjustable to different depths.
            scenePath = fullfile(piRootPath,'data',...
                'V3','slantedBarTexture',...
                'slantedBarTexture.pbrt');
            sceneUnits = 'm';
            
            
        otherwise
            error('Did not recognize scene type.');
    end
    
end

%% Read the filename and get a thisR
thisR = piRead(scenePath,'version',3);
thisR.inputFile = scenePath;

%% Setup the working folder
if(isempty(se_p.Results.workingDirectory))
    % Determine scene folder name from scene path
    [path, ~, ~] = fileparts(scenePath);
    [~, sceneFolder] = fileparts(path);
    workingDir = fullfile(...
        isetbioRootPath, 'local', sceneFolder);
else
    workingDir = p.Results.workingDirectory;
end

% Copy contents of the working folder over to the local folder.
origPath = createWorkingFolder(...
    scenePath, 'workingDir', workingDir);
            
%% Make adjustments to the recipe, thisR
%
% E.g. move the plane to a certain distance
if(sceneNameFlag)
    
    switch sceneName
        
        case('slantedBar')
            thisR = piObjectTransform(thisR, 'SlantedBar', ...
                'Translate', [0 0 se_p.Results.planeDistance]);
        
        case('slantedBarAdjustable')
            % A variation of slantedBar where the black and white planes
            % are adjustable to different depths. We reread the thisR
            % since we already have piCreateSlantedBarScene. 
            thisR = piCreateSlantedBarScene(...
                'whiteDepth',se_p.Results.whiteDepth,...
                'blackDepth',se_p.Results.blackDepth);
            
        case('slantedBarTexture')
            % A variation of slantedBar where the two planes are
            % adjustable to different depths and they have a texture
            % pattern. We reread the thisR since we already have
            % piCreateSlantedBarScene.
            thisR = piCreateSlantedBarTextureScene(...
                'frontDepth',se_p.Results.frontDepth,...
                'backDepth',se_p.Results.backDepth);
            
        case('pointSource')
            % Clear previous transforms
            piClearObjectTransforms(thisR,'Point');
            piClearObjectTransforms(thisR,'Plane');
            % Add given transforms
            thisR = piObjectTransform(thisR,'Point','Scale',[se_p.Results.pointDiameter se_p.Results.pointDiameter 1]);
            thisR = piObjectTransform(thisR,'Point','Translate',[0 0 se_p.Results.pointDistance]);
            % Make it large!
            thisR = piObjectTransform(thisR,'Plane','Scale',[se_p.Results.pointDistance*10 se_p.Results.pointDistance*10 1]);
            % Move it slightly beyond the point
            thisR = piObjectTransform(thisR,'Plane','Translate',[0 0 se_p.Results.pointDistance+0.5]);
         
        case('snellenSingle')
            scaling = [se_p.Results.objectSize(1) se_p.Results.objectSize(2) 1] ./ [1 1 1];
            thisR = piObjectTransform(thisR,'Snellen','Scale',scaling);
            thisR = piObjectTransform(thisR, 'Snellen', ...
                'Translate', [0 0 se_p.Results.objectDistance]);
            
        case('texturedPlane')
            % Scale and translate
            planeSize = se_p.Results.planeSize;
            scaling = [planeSize(1) planeSize(2) 1] ./ [1 1 1];
            thisR = piObjectTransform(thisR, 'Plane', 'Scale', scaling);
            thisR = piObjectTransform(thisR, 'Plane', ...
                'Translate', [0 0 se_p.Results.planeDistance]);
            % Texture
            [pathTex, nameTex, extTex] = fileparts(se_p.Results.planeTexture);
            copyfile(se_p.Results.planeTexture, workingDir);
            if(isempty(pathTex))
                error('Image texture must be an absolute path.');
            end
            thisR = piWorldFindAndReplace(thisR, 'dummyTexture.exr', ...
                strcat(nameTex, extTex));
            
            % If true, use the lcd-apple display primaries to convert to
            % RGB texture values to spectra.
            if(se_p.Results.useDisplaySPD)
                thisR = piWorldFindAndReplace(thisR, '"bool useSPD" "false"', ...
                    '"bool useSPD" "true"');
            end
            
            % If true, we convert from sRGB to lRGB in PBRT. 
            if(strcmp(se_p.Results.gamma,'false'))
                thisR = piWorldFindAndReplace(thisR,'"bool gamma" "true"',...
                    '"bool gamma" "false"');
            end
    end
end

