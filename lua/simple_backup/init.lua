local M = {}

-- 默认配置
local default_config = {
    backup_dir = ".history",           -- 备份目录名
    timestamp_format = "%Y%m%d%H%M%S", -- 时间戳格式
    enabled = true,                    -- 是否启用插件
    exclude_dirs = nil,                -- 排除目录
    exclude_files = nil,               -- 排除文件模式
    include_dirs = nil,                -- 包含目录模式，nil表示不启用
    include_files = nil,               -- 包含文件模式，nil表示不启用
    verbose = true,                    -- 是否显示备份信息
}

-- 合并用户配置
M.config = vim.deepcopy(default_config)

function M.setup(user_config)
    M.config = vim.tbl_deep_extend("force", default_config, user_config or {})
end

-- 主备份函数
local function backup_file()
    if not M.config.enabled or not vim.bo.modified then
        return
    end

    local current_file = vim.fn.expand("%:p")
    local timestamp = os.date(M.config.timestamp_format)
    local file_name = vim.fn.expand("%:t:r")    -- 文件名（不含扩展名）
    local file_extension = vim.fn.expand("%:e") -- 扩展名

    -- 新增：检查是否在包含列表中（如果配置了include_files）
    if M.config.include_files then
        local matched = false
        for _, pattern in ipairs(M.config.include_files) do
            if vim.fn.fnamemodify(current_file, ":t") == pattern or
                vim.fn.fnamemodify(current_file, ":t"):match(pattern) then
                matched = true
                break
            end
        end
        if not matched then
            return
        end
    end

    -- 原有：检查是否在排除列表中
    for _, pattern in ipairs(M.config.exclude_files) do
        if vim.fn.fnamemodify(current_file, ":t") == pattern or
            vim.fn.fnamemodify(current_file, ":t"):match(pattern) then
            return
        end
    end

    -- 查找 .venv 目录
    local venv_dir = vim.fn.finddir(".venv", ".;")
    if venv_dir == "" then
        if M.config.verbose then
            print("[simple-backup] Error: .venv directory not found!")
        end
        return
    end

    -- 获取项目根目录（.venv 的父目录）
    local project_root = vim.fn.fnamemodify(venv_dir, ":h")

    -- 标准化路径处理（Windows 兼容）
    local normalized_root = vim.fn.fnamemodify(project_root, ":p"):gsub("\\", "/")
    if normalized_root:sub(-1) ~= "/" then
        normalized_root = normalized_root .. "/"
    end

    local normalized_file = vim.fn.fnamemodify(current_file, ":p"):gsub("\\", "/")

    -- 新增：检查是否在包含目录中（如果配置了include_dirs）
    if M.config.include_dirs then
        local matched = false
        for _, dir in ipairs(M.config.include_dirs) do
            if normalized_file:find("/" .. dir .. "/") then
                matched = true
                break
            end
        end
        if not matched then
            return
        end
    end

    -- 原有：检查是否在排除目录中
    for _, dir in ipairs(M.config.exclude_dirs) do
        if normalized_file:find("/" .. dir .. "/") then
            return
        end
    end

    -- 提取相对路径（移除项目根目录前缀）
    if normalized_file:sub(1, #normalized_root) ~= normalized_root then
        if M.config.verbose then
            print("[simple-backup] Error: File not in project: " .. current_file)
        end
        return
    end
    local relative_path = normalized_file:sub(#normalized_root + 1)

    -- 创建备份目录路径
    local backup_dir = normalized_root .. M.config.backup_dir .. "/" .. vim.fn.fnamemodify(relative_path, ":h")

    -- 创建带时间戳的备份文件名
    local backup_file = backup_dir .. "/" .. file_name .. "_" .. timestamp
    if file_extension ~= "" then
        backup_file = backup_file .. "." .. file_extension
    end

    -- 创建目录（递归）
    if vim.fn.isdirectory(backup_dir) == 0 then
        vim.fn.mkdir(backup_dir, "p")
    end

    -- 执行备份
    local success, err = pcall(function()
        vim.fn.writefile(vim.fn.readfile(current_file), backup_file)
    end)

    if success and M.config.verbose then
        print("[simple-backup] Backup saved to: " .. backup_file)
    elseif not success then
        print("[simple-backup] Error saving backup: " .. err)
    end

    -- 清除修改标志，避免无限循环
    vim.cmd("set nomodified")
end

-- 初始化插件
function M.enable()
    -- 创建自动命令组
    vim.api.nvim_create_augroup("SimpleBackup", { clear = true })

    -- 绑定自动命令（所有文件保存时触发）
    vim.api.nvim_create_autocmd("BufWritePre", {
        group = "SimpleBackup",
        pattern = "*",
        callback = backup_file,
    })
end

-- 禁用插件
function M.disable()
    vim.api.nvim_del_augroup_by_name("SimpleBackup")
end

-- 自动启用
M.enable()

return M
