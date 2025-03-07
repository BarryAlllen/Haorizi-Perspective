function perspective_gui()
    % 初始化 GUI 组件，使用归一化单位
    fig = figure('Name', '好日子透视矫正处理工具', 'NumberTitle', 'off', 'Position', [100, 100, 1024, 800], 'Units', 'normalized', 'ResizeFcn', @resizeUI);

    % 创建面板
    statusPanel = uipanel('Title', 'Status', 'FontSize', 10, 'Position', [0.01 0.91 0.98 0.077]);
    controlPanel = uipanel('Title', 'Controls', 'FontSize', 10, 'Position', [0.01 0.01 0.98 0.14]);
    imagePanel = uipanel('Title', 'Image', 'FontSize', 10, 'Position', [0.01 0.16 0.98 0.74]);

    % 状态面板中的状态标签和显示
    default_status = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '请选择目录', 'ForegroundColor', [0.7 0 0], 'Units', 'normalized', 'Position', [0.02, 0.1, 0.09, 0.72], 'FontSize', 12, 'Visible', 'on');
    processedCount_label = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '处理数量:', 'Units', 'normalized', 'Position', [0.01, 0.1, 0.09, 0.72], 'FontSize', 12, 'Visible', 'off');
    processedCountDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '0', 'ForegroundColor', [0 0.7 0], 'Units', 'normalized', 'Position', [0.105, 0.1, 0.04, 0.72], 'HorizontalAlignment', 'left', 'FontSize', 12, 'Visible', 'off');

    currentImage_label = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '当前图像:', 'Units', 'normalized', 'Position', [0.22, 0.1, 0.09, 0.72], 'FontSize', 12, 'Visible', 'off');
    currentImageDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '0 / 0', 'ForegroundColor', [0 0 0.7], 'Units', 'normalized', 'Position', [0.313, 0.1, 0.2, 0.72], 'HorizontalAlignment', 'left', 'FontSize', 12, 'Visible', 'off');

    fileName_label = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '文件名:', 'Units', 'normalized', 'Position', [0.46, 0.1, 0.07, 0.72], 'FontSize', 12, 'Visible', 'off');
    fileNameDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '', 'ForegroundColor', [0 0 0.7], 'Units', 'normalized', 'Position', [0.535, 0.1, 0.2, 0.72], 'FontSize', 12, 'HorizontalAlignment', 'left', 'Visible', 'off');

    chooseButton = uicontrol('Parent', statusPanel, 'Style', 'pushbutton', 'String', '选择序号', 'Units', 'normalized', 'Position', [0.901, 0.1, 0.09, 0.85], 'FontSize', 11, 'Visible', 'off', 'Callback', @jumpToImage);

    % 控制面板中的目录路径按钮和编辑框
    sourceButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '选择源目录', 'FontSize', 11, 'Units', 'normalized', 'Position', [0.01, 0.55, 0.15, 0.4], 'Callback', @selectSourceDir);
    sourceDirEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', 'Units', 'normalized', 'Position', [0.17, 0.55, 0.62, 0.4], 'FontSize', 11, 'Enable', 'off');

    targetButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '选择目标目录', 'FontSize', 11, 'Units', 'normalized', 'Position', [0.01, 0.05, 0.15, 0.4], 'Callback', @selectTargetDir);
    targetDirEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', 'Units', 'normalized', 'Position', [0.17, 0.05, 0.62, 0.4], 'FontSize', 11, 'Enable', 'off');

    % 导航和处理按钮，初始禁用
    processButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '处理', 'Units', 'normalized', 'Position', [0.80, 0.55, 0.09, 0.4], 'FontSize', 11, 'Enable', 'off', 'Callback', @processCurrentImage);
    prevButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '上一张', 'Units', 'normalized', 'Position', [0.80, 0.05, 0.09, 0.4], 'FontSize', 11, 'Enable', 'off', 'Callback', @previousImage);
    nextButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '下一张', 'Units', 'normalized', 'Position', [0.90, 0.05, 0.09, 0.4], 'FontSize', 11, 'Enable', 'off', 'Callback', @nextImage);

    % 添加旋转按钮
    rotateButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '旋转90°', 'Units', 'normalized', 'Position', [0.90, 0.55, 0.09, 0.4], 'FontSize', 11, 'Enable', 'off', 'Callback', @rotateImage);

    % 图像显示轴
    ax = axes('Parent', imagePanel, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.9]);
    axis off;

    imageList = [];
    currentIndex = 0;
    totalImages = 0;
    processedCount = 0;

    function resizeUI(~, ~)
        % 调整面板位置
        statusPanel.Position = [0.01 0.91 0.98 0.077];
        controlPanel.Position = [0.01 0.01 0.98 0.14];
        imagePanel.Position = [0.01 0.16 0.98 0.74];
    end

    function jumpToImage(src, event)
        % 跳转到指定图像
        prompt = {'请输入您希望跳转到的图片序号:'};
        title = '跳转到特定图片';
        dims = [1 55];
        definput = {num2str(currentIndex)};
        answer = inputdlg(prompt, title, dims, definput, 'on');

        if ~isempty(answer)
            newIndex = str2double(answer{1});
            if newIndex >= 1 && newIndex <= numel(imageList)
                currentIndex = newIndex;
                displayCurrentImage();
            else
                errordlg('输入的索引无效，请输入有效的图片序号。', '索引错误');
            end
        end
    end

    function updateStatusInfo()
        % 更新状态信息
        set(processedCountDisplay, 'String', num2str(processedCount));
        set(currentImageDisplay, 'String', sprintf('%d / %d', currentIndex, totalImages));
    end

    function selectSourceDir(~, ~)
        % 选择源目录
        folder_name = uigetdir;
        if folder_name ~= 0
            set(sourceDirEdit, 'String', folder_name);
            refreshImageList(folder_name);
            set(default_status, 'Visible', 'off');
            set([processedCount_label, processedCountDisplay, currentImage_label, currentImageDisplay, fileName_label, fileNameDisplay, chooseButton], 'Visible', 'on');
            enableButtonsIfReady();
            processedCount = 0;
            updateStatusInfo();
        end
    end

    function selectTargetDir(~, ~)
        % 选择目标目录
        folder_name = uigetdir;
        if folder_name ~= 0
            set(targetDirEdit, 'String', folder_name);
            enableButtonsIfReady();
        end
    end

    function enableButtonsIfReady()
        % 如果源和目标目录都已选择，则启用按钮
        sourceDir = get(sourceDirEdit, 'String');
        targetDir = get(targetDirEdit, 'String');
        if ~isempty(sourceDir) && ~isempty(targetDir) && isfolder(sourceDir) && isfolder(targetDir)
            set([nextButton, processButton, rotateButton, chooseButton], 'Enable', 'on');
        else
            set([prevButton, nextButton, processButton, rotateButton, chooseButton], 'Enable', 'off');
        end
    end

    function refreshImageList(folder)
        % 刷新图像列表
        extensions = {'*.bmp', '*.jpg', '*.jpeg', '*.png'};
        imageFiles = [];

        for i = 1:length(extensions)
            newFiles = dir(fullfile(folder, extensions{i}));
            imageFiles = [imageFiles; newFiles];
        end

        imageList = {imageFiles.name};
        totalImages = length(imageList);
        fprintf('Directory: %s\n', folder);
        fprintf('Found %d images.\n', numel(imageList));

        if ~isempty(imageList)
            currentIndex = 1;
            displayCurrentImage();
        else
            disp('No images found in the directory.');
        end
    end

    function previousImage(~, ~)
        % 显示上一张图像
        if currentIndex > 1
            currentIndex = currentIndex - 1;
            displayCurrentImage();
        end

        if currentIndex <= 1
            displayCurrentImage();
        end
    end

    function nextImage(~, ~)
        % 显示下一张图像
        if currentIndex < numel(imageList)
            currentIndex = currentIndex + 1;
            displayCurrentImage();
        end

        if currentIndex >= numel(imageList)
            displayCurrentImage();
        end
    end

    function updateButtonStates(currentIndex, totalImages, prevButton, nextButton)
        % 更新按钮状态
        if currentIndex <= 1
            set(prevButton, 'Enable', 'off');
        else
            set(prevButton, 'Enable', 'on');
        end

        if currentIndex >= totalImages
            set(nextButton, 'Enable', 'off');
        else
            set(nextButton, 'Enable', 'on');
        end
    end

    function displayCurrentImage()
        % 显示当前图像
        if ~isempty(imageList)
            imgPath = fullfile(get(sourceDirEdit, 'String'), imageList{currentIndex});
            img = im2double(imread(imgPath));
            cla(ax);
            imshow(img, 'Parent', ax);
            axis image;
            axis off;
            updateButtonStates(currentIndex, numel(imageList), prevButton, nextButton);
            updateStatusInfo();
            [~, name, ext] = fileparts(imageList{currentIndex});
            set(fileNameDisplay, 'String', [name ext]);
        end
    end

    function processCurrentImage(~, ~)
        % 处理当前图像
        set([sourceButton, targetButton, prevButton, nextButton, processButton, rotateButton, chooseButton], 'Enable', 'off');
        if ~isempty(imageList)
            imgPath = fullfile(get(sourceDirEdit, 'String'), imageList{currentIndex});
            img = imread(imgPath);
            imshow(img, 'Parent', ax); hold on;

            imgSize = size(img);
            imgHeight = imgSize(1);
            imgWidth = imgSize(2);

            loc_x = zeros(1, 4);
            loc_y = zeros(1, 4);
            pointHandles = gobjects(1, 4);

            for p = 1:4
                while true
                    [x, y, button] = ginput(1);
                    if button == 3
                        delete(pointHandles(pointHandles ~= 0));
                        set([sourceButton, targetButton, prevButton, nextButton, processButton, rotateButton, chooseButton], 'Enable', 'on');
                        return;
                    end
                    if x >= 1 && x <= imgWidth && y >= 1 && y <= imgHeight
                        break;
                    else
                        disp('Clicked outside the image, please click within the image boundaries.');
                    end
                end
                loc_x(p) = x;
                loc_y(p) = y;
                pointHandles(p) = plot(x, y, 'r.');
            end

            loc_x = floor(loc_x);
            loc_y = floor(loc_y);
            [X, Y] = my_sort(loc_x, loc_y, img);
            I = my_pres_trans(img, X, Y, 128, 128);
            targetPath = get(targetDirEdit, 'String');
            [~, name, ext] = fileparts(imageList{currentIndex});
            pathfile = fullfile(targetPath, [name, ext]);
            imwrite(I, pathfile);
            processedCount = processedCount + 1;

            delete(pointHandles(pointHandles ~= 0));
        end
        set([sourceButton, targetButton, prevButton, nextButton, processButton, rotateButton, chooseButton], 'Enable', 'on');
        displayCurrentImage();
        pause(0.5);
        nextImage();
    end

    function rotateImage(~, ~)
        % 旋转当前图像
        if ~isempty(imageList)
            imgPath = fullfile(get(sourceDirEdit, 'String'), imageList{currentIndex});
            img = imread(imgPath);
            rotatedImg = imrotate(img, -90); % 顺时针旋转90度

            % 覆盖原始图像
            imwrite(rotatedImg, imgPath);

            % 重新显示旋转后的图像
            displayCurrentImage();
        end
    end
end