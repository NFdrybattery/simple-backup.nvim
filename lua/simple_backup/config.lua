return {
    backup_dir = ".history",           -- 备份目录名
    timestamp_format = "%Y%m%d%H%M%S", -- 时间戳格式
    enabled = true,                    -- 是否启用插件
    exclude_dirs = nil,                -- 排除目录
    exclude_files = nil,               -- 排除文件模式
    include_dirs = nil,                -- 包含目录模式，nil表示不启用
    include_files = nil,               -- 包含文件模式，nil表示不启用
    verbose = true,                    -- 是否显示备份信息
}
