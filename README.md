# simple-backup.nvim

Neovim 插件，用于在python文件保存时自动创建带时间戳的备份。兼容Vscode/local_history插件。

## 功能

- 自动备份修改过的文件
- 可配置的备份目录和时间戳格式
- 支持包含/排除特定文件类型，默认不排除
- 支持包含/排除特定目录，默认不排除
- 详细的日志输出

## 配置

```lua
require('simple_backup').setup({
    backup_dir = ".history",           -- 备份目录名
    timestamp_format = "%Y%m%d_%H%M%S", -- 时间戳格式
    enabled = true,                    -- 是否启用插件
    
    -- 排除配置
    exclude_dirs = { ".git", "node_modules" }, -- 排除目录
    exclude_files = { "*.tmp", "*.bak" },      -- 排除文件模式
    
    -- 包含配置（可选）
    include_dirs = nil,                -- 包含目录模式，nil表示不启用
    include_files = nil,               -- 包含文件模式，nil表示不启用
    verbose = true,                    -- 是否显示备份信息
})
```

### 配置示例

1. 只备份特定文件类型：
```lua
require('simple_backup').setup({
    include_files = {"*.lua", "*.py"},  -- 只备份这些文件
    exclude_files = nil                 -- 禁用排除文件
})
```

2. 只备份特定目录：
```lua
require('simple_backup').setup({
    include_dirs = {"src", "lib"},      -- 只备份这些目录
    exclude_dirs = nil                  -- 禁用排除目录
})
```

3. 组合使用包含和排除：
```lua
require('simple_backup').setup({
    include_files = {"*.lua", "*.py"},  -- 只备份这些文件
    exclude_files = {"test_*.lua"},     -- 但不备份测试文件
    include_dirs = {"src"},             -- 只备份src目录
    exclude_dirs = {"src/tests"}        -- 但不备份src/tests目录
})
```

## 安装

使用你喜欢的插件管理器安装。
**packer.nvim**：
```lua
use {
    'NFdrybattery/simple-backup.nvim',
    lazy = true,
    config = function()
        require('simple_backup').setup({
            -- 自定义配置
            backup_dir = ".history",
        })
    end
}
```
**Lazyvim**：
```lua
return {
  {
    'NFdrybattery/simple-backup.nvim',
    event = "VeryLazy",
    config = function()
      require('simple_backup').setup({
        backup_dir = ".history",       -- 备份目录名
        include_files = {"*.py"},      -- 只备份python文件
      })
    end
  }
}
```