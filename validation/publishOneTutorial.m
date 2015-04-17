function publishOneTutorial

    % ------- script customization - adapt to your environment/project -----
    
    % user/project specific preferences
    p = struct(...
        'rootDirectory',            fileparts(which(mfilename())), ...                         % the rootDirectory
        'ghPagesCloneDir',          getpref('isetbioValidation', 'clonedGhPagesLocation'), ... % local directory where the project's gh-pages branch is cloned
        'wikiCloneDir',             getpref('isetbioValidation', 'clonedWikiLocation'), ...    % local directory where the project's wiki is cloned
        'tutorialsSourceDir',       fullfile(isetbioRootPath, 'tutorials'), ...                % local directory where tutorial scripts are located
        'tutorialsTargetHTMLsubdir','tutorialdocs', ...                                        % local subdirectory (of ghPagesCloneDir) where the published HTML files will go
        'headerText',               '***\n_This file is autogenerated by the ''publishAllTutorials'' script, located in the $isetbioRoot/validation directory. Do not edit manually, as all changes will be overwritten during the next run._\n***',...
        'verbosity',                1 ...
    );

    % list of scripts to be skipped from automatic publishing
    scriptsToSkip = {};
    % ----------------------- end of script customization -----------------
    
    UnitTest.publishProjectTutorials(p, scriptsToSkip, 'Single');
end


