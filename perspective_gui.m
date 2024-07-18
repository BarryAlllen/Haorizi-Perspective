function perspective_gui()
    % Initialize GUI components with normalized units
    fig = figure('Name', '好日子透视矫正处理工具', 'NumberTitle', 'off', 'Position', [100, 100, 1024, 800], 'Units', 'normalized', 'ResizeFcn', @resizeUI);

    % Create panels
    statusPanel = uipanel('Title', 'Status', 'FontSize', 10, 'Position', [0.01 0.91 0.98 0.077]);  % Significantly reduced the height
    controlPanel = uipanel('Title', 'Controls', 'FontSize', 10, 'Position', [0.01 0.01 0.98 0.14]);  % Kept more space for controls
    imagePanel = uipanel('Title', 'Image', 'FontSize', 10, 'Position', [0.01 0.16 0.98 0.74]);  % Adjusted to fit the remaining space


    % Status labels and displays within status panel
    default_status = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '请选择目录', 'ForegroundColor', [0.7 0 0], 'Units', 'normalized', 'Position', [0.02, 0.1, 0.09, 0.72], 'FontSize', 12,'Visible','on');
    processedCount_label = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '处理数量:', 'Units', 'normalized', 'Position', [0.01, 0.1, 0.09, 0.72], 'FontSize', 12,'Visible','off');
    processedCountDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '0', 'ForegroundColor', [0 0.7 0], 'Units', 'normalized', 'Position', [0.105, 0.1, 0.04, 0.72], 'HorizontalAlignment', 'left', 'FontSize', 12,'Visible','off');
    
    currentImage_label = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '当前图像:', 'Units', 'normalized', 'Position', [0.22, 0.1, 0.09, 0.72], 'FontSize', 12,'Visible','off');
    currentImageDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '0 / 0', 'ForegroundColor', [0 0 0.7], 'Units', 'normalized', 'Position', [0.313, 0.1, 0.2, 0.72], 'HorizontalAlignment', 'left', 'FontSize', 12,'Visible','off');
    
    fileName_label = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '文件名:', 'Units', 'normalized', 'Position', [0.46, 0.1, 0.07, 0.72], 'FontSize', 12,'Visible','off');
    fileNameDisplay = uicontrol('Parent', statusPanel, 'Style', 'text', 'String', '', 'ForegroundColor', [0 0 0.7], 'Units', 'normalized', 'Position', [0.535, 0.1, 0.2, 0.72], 'FontSize', 12, 'HorizontalAlignment', 'left','Visible','off');
    
    chooseButton = uicontrol('Parent', statusPanel, 'Style', 'pushbutton', 'String', '选择图片', 'Units', 'normalized', 'Position', [0.901, 0.1, 0.09, 0.85], 'FontSize', 11,'Visible','off', 'Callback', @jumpToImage);

    % Buttons and edit fields for directory paths within control panel
    sourceButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '选择源目录', 'FontSize', 11, 'Units', 'normalized', 'Position', [0.01, 0.55, 0.15, 0.4], 'Callback', @selectSourceDir);
    sourceDirEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', 'Units', 'normalized', 'Position', [0.17, 0.55, 0.62, 0.4], 'FontSize', 11, 'Enable', 'off');

    targetButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '选择目标目录', 'FontSize', 11, 'Units', 'normalized', 'Position', [0.01, 0.05, 0.15, 0.4], 'Callback', @selectTargetDir);
    targetDirEdit = uicontrol('Parent', controlPanel, 'Style', 'edit', 'Units', 'normalized', 'Position', [0.17, 0.05, 0.62, 0.4], 'FontSize', 11, 'Enable', 'off');

    % Navigation and processing buttons initially disabled
    processButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '处理当前图像', 'Units', 'normalized', 'Position', [0.80, 0.55, 0.19, 0.4], 'FontSize', 11, 'Enable', 'off', 'Callback', @processCurrentImage);
    prevButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '上一张', 'Units', 'normalized', 'Position', [0.80, 0.05, 0.09, 0.4], 'FontSize', 11, 'Enable', 'off', 'Callback', @previousImage);
    nextButton = uicontrol('Parent', controlPanel, 'Style', 'pushbutton', 'String', '下一张', 'Units', 'normalized', 'Position', [0.90, 0.05, 0.09, 0.4], 'FontSize', 11, 'Enable', 'off', 'Callback', @nextImage);

    % Image display axis within image panel
    ax = axes('Parent', imagePanel, 'Units', 'normalized', 'Position', [0.05 0.05 0.9 0.9]);
    axis off;

    imageList = [];
    currentIndex = 0;
    totalImages = 0;
    processedCount = 0;


    function resizeUI(~, ~)
        % Adjust panels proportionally as the figure window resizes
        statusPanel.Position = [0.01 0.91 0.98 0.077];
        controlPanel.Position = [0.01 0.01 0.98 0.14];
        imagePanel.Position = [0.01 0.16 0.98 0.74];
    end

    function jumpToImage(src, event)
        prompt = {'请输入您希望跳转到的图片序号:'};  % 更详细的提示
        title = '跳转到特定图片';  % 更具吸引力的标题
        dims = [1 55];  % 调整对话框的宽度

        definput = {num2str(currentIndex)};  % 提供当前图片序号作为默认输入
        answer = inputdlg(prompt, title, dims, definput, 'on');
    
        if ~isempty(answer)
            newIndex = str2double(answer{1});
            if newIndex >= 1 && newIndex <= numel(imageList)
                currentIndex = newIndex;
                displayCurrentImage();  % 跳转并显示新的图片
            else
                errordlg('输入的索引无效，请输入有效的图片序号。', '索引错误');  % 更友好的错误消息
            end
        end
    end
   

    function updateStatusInfo()
        % Update the status display labels
        set(processedCountDisplay, 'String', num2str(processedCount));
        set(currentImageDisplay, 'String', sprintf('%d / %d', currentIndex, totalImages));
    end


    function selectSourceDir(~, ~)
        folder_name = uigetdir;
        if folder_name ~= 0
            set(sourceDirEdit, 'String', folder_name);
            refreshImageList(folder_name);
            set(default_status, 'Visible', 'off');
            set([processedCount_label, processedCountDisplay, currentImage_label, currentImageDisplay, fileName_label, fileNameDisplay, chooseButton], 'Visible', 'on');
            enableButtonsIfReady();
        end
    end


    function selectTargetDir(~, ~)
        folder_name = uigetdir;
        if folder_name ~= 0
            set(targetDirEdit, 'String', folder_name);
            enableButtonsIfReady();
        end
    end


    function enableButtonsIfReady()
        % Check if both directories are selected
        sourceDir = get(sourceDirEdit, 'String');
        targetDir = get(targetDirEdit, 'String');
        if ~isempty(sourceDir) && ~isempty(targetDir) && isfolder(sourceDir) && isfolder(targetDir)
            set([nextButton, processButton, chooseButton], 'Enable', 'on');
        else
            set([prevButton, nextButton, processButton, chooseButton], 'Enable', 'off');
        end
    end

    
    function refreshImageList(folder)
        % 定义支持的文件扩展名列表
        extensions = {'*.bmp', '*.jpg', '*.jpeg', '*.png'};
        imageFiles = [];
        
        % 循环遍历每种文件类型，并收集所有匹配的文件
        
        for i = 1:length(extensions)
            newFiles = dir(fullfile(folder, extensions{i}));
            imageFiles = [imageFiles; newFiles]; % 使用数组合并来收集所有文件
        end
        
        % 提取文件名并存储在 imageList 中
        imageList = {imageFiles.name};
        totalImages = length(imageList);
        fprintf('Directory: %s\n', folder);
        fprintf('Found %d images.\n', numel(imageList));
        
        % 如果找到图像，则显示第一张图像，否则输出没有找到图像的消息
        if ~isempty(imageList)
            currentIndex = 1;
            displayCurrentImage();
        else
            disp('No images found in the directory.');
        end
    end


    function previousImage(~, ~)
        if currentIndex > 1
            currentIndex = currentIndex - 1;
            displayCurrentImage();
        end
    end
    

    function nextImage(~, ~)
        if currentIndex < numel(imageList)
            currentIndex = currentIndex + 1;
            displayCurrentImage();
        end
    end


    function updateButtonStates(currentIndex, totalImages, prevButton, nextButton)
        if currentIndex <= 1
            set(prevButton, 'Enable', 'off');  % 如果是第一张图，禁用“上一张”按钮
        else
            set(prevButton, 'Enable', 'on');  % 否则启用“上一张”按钮
        end
    
        if currentIndex >= totalImages
            set(nextButton, 'Enable', 'off');  % 如果是最后一张图，禁用“下一张”按钮
        else
            set(nextButton, 'Enable', 'on');  % 否则启用“下一张”按钮
        end
    end


    function displayCurrentImage()
        if ~isempty(imageList)
            imgPath = fullfile(get(sourceDirEdit, 'String'), imageList{currentIndex});
            img = im2double(imread(imgPath));
            cla(ax);
            imshow(img, 'Parent', ax);
            axis image;  % 设置轴以匹配图像的尺寸和比例
            axis off;  % 关闭轴标记
            updateButtonStates(currentIndex, numel(imageList), prevButton, nextButton);
            updateStatusInfo();
            % 更新当前图像的文件名
            [~, name, ext] = fileparts(imageList{currentIndex});
            set(fileNameDisplay, 'String', [name ext]);  % 显示文件名和扩展名
        end
    end


    function processCurrentImage(~, ~)
        set([sourceButton, targetButton, prevButton, nextButton, processButton, chooseButton], 'Enable', 'off');
        if ~isempty(imageList)
            imgPath = fullfile(get(sourceDirEdit, 'String'), imageList{currentIndex});
            img = imread(imgPath);
            imshow(img, 'Parent', ax); hold on;
            
            % 获取图像尺寸
            imgSize = size(img);
            imgHeight = imgSize(1);
            imgWidth = imgSize(2);
    
            % 初始化点选坐标数组
            loc_x = zeros(1, 4);
            loc_y = zeros(1, 4);
            pointHandles = gobjects(1, 4);
    
            % 等待鼠标输入，最多4次
            for p = 1:4
                while true
                    [x, y, button] = ginput(1);
                    if button == 3  % 如果检测到右键点击
                        delete(pointHandles(pointHandles ~= 0));
                        set([sourceButton, targetButton, prevButton, nextButton, processButton, chooseButton], 'Enable', 'on');
                        return;  % 退出函数
                    end
                    % 检查是否在图像边界内
                    if x >= 1 && x <= imgWidth && y >= 1 && y <= imgHeight
                        break;  % 退出循环，接受当前点
                    else
                        disp('Clicked outside the image, please click within the image boundaries.');
                    end
                end
                loc_x(p) = x;
                loc_y(p) = y;
                pointHandles(p) = plot(x, y, 'r.');  % 显示选点
            end
            
            % 处理图像逻辑
            loc_x = floor(loc_x);
            loc_y = floor(loc_y);
            [X, Y] = my_sort(loc_x, loc_y, img);
            I = my_pres_trans(img, X, Y, 128, 128);
            targetPath = get(targetDirEdit, 'String');
            [~, name, ext] = fileparts(imageList{currentIndex});
            pathfile = fullfile(targetPath, [name, '_re', ext]);
            imwrite(I, pathfile);
            processedCount = processedCount + 1;
    
            delete(pointHandles(pointHandles ~= 0));  % 清除点
        end
        set([sourceButton, targetButton, prevButton, nextButton, processButton, chooseButton], 'Enable', 'on');
    
        nextImage();
    end


end
