function t_fixationalEMConeSampling
% Examine the effects of different cone mosaic resampling factors
% on the resulting eye movement paths.
%

% History
%   02/06/18  npc  Wrote it.

    close all;
    
    % cone mosaic params
    fovDegs = 0.1;
    integrationTime = 1/1000;
    resamplingFactors = [1 3 6 13];
    
    % Stimulus params for a pulse stimulus
    sceneParams = struct('fov', fovDegs, 'luminance', 100);
    stimRefreshInterval = 10/1000;
    stimWeights = zeros(1,50); stimWeights(4) = 1;
    sampleTimes = stimRefreshInterval*((1:length(stimWeights))-1);
    
    % Generate an oiSequence for the pulse stimulus
    theOIsequence = oisCreate('impulse','add', stimWeights, ...
        'sampleTimes', sampleTimes, ...
        'sceneParameters', sceneParams);
    
    % Instantiate a fixational eye movement object
    fixEMobj = fixationalEM();
    nTrials = 2;
    
    % Set up figure
    vcNewGraphWin([], 'tall'); 
    colors = [1 0 0; 0 0 1; 0 0 0; 0.4 0.4 0.4];
    legends = {};
    
    for iSampleIndex = 1:numel(resamplingFactors)  
        % Instantiate a hex mosaic with a specific resampling factor
        cm = coneMosaicHex(resamplingFactors(iSampleIndex), 'fovDegs', fovDegs);
        cm.integrationTime = integrationTime;
        legends{numel(legends)+1} = sprintf('resampling: %2.0f ms', resamplingFactors(iSampleIndex));
        
        % Compute the number of eye movements for this integration time and oiSequence
        eyeMovementsPerTrial = theOIsequence.maxEyeMovementsNumGivenIntegrationTime(cm.integrationTime);
        
        % Compute emPath for this mosaic using same random seed, so we can
        % compare the effects of different time sampling.
        fixEMobj.computeForConeMosaic(cm, eyeMovementsPerTrial, ...
            'nTrials', nTrials, ...
            'computeVelocity', true, ...
            'rSeed', 1);
    
        % Visualize the first trial emPath and velocity
        visualizedTrial = 1;
        subplot(3,1,1);
        hold on
        plot(fixEMobj.timeAxis*1000, squeeze(fixEMobj.emPosArcMin(visualizedTrial,:,1)), 's-', ...
            'LineWidth', 1.5, ...
            'MarkerSize', 4, 'MarkerFaceColor', [0.8 0.8 0.8], ...
            'Color', squeeze(colors(iSampleIndex,:)));
        legend(legends, 'Location', 'NorthWest');
        xlabel('time (ms)')
        ylabel('x-position (arc min)');
        grid on
        set(gca, 'FontSize', 14);
        
        subplot(3,1,2);
        hold on
        plot(fixEMobj.timeAxis*1000, squeeze(fixEMobj.emPosArcMin(visualizedTrial,:,2)), 's-', ...
            'LineWidth', 1.5, ...
            'MarkerSize', 4, 'MarkerFaceColor', [0.8 0.8 0.8], ...
            'Color', squeeze(colors(iSampleIndex,:)));
        legend(legends, 'Location', 'NorthWest');
        xlabel('time (ms)')
        ylabel('y-position (arc min)');
        grid on
        set(gca, 'FontSize', 14);
        
        subplot(3,1,3);
        hold on
        plot(fixEMobj.timeAxis*1000, squeeze(fixEMobj.velocityArcMin(visualizedTrial,:)), 's-', ...
            'LineWidth', 1.5, ...
            'MarkerSize', 4, 'MarkerFaceColor', [0.8 0.8 0.8], ...
            'Color', squeeze(colors(iSampleIndex,:)));
        legend(legends, 'Location', 'NorthWest');
        xlabel('time (ms)')
        ylabel('velocity (arc min / sec)');
        grid on
        set(gca, 'FontSize', 14);
    end
    
end
