# HIT(SZ) 本科开题报告 Typst 模板

这是哈尔滨工业大学（深圳）本科毕业论文（设计）开题报告 Typst 模板。模板包含：

- `hit-opening.typ`：主模板；
- `hit-gb7714.csl`：GB/T 7714—2015 numeric 引用样式；
- `szbachelor-checked.svg`：封面复选框矢量资源；
- `example/`：示例正文、BibTeX 和图片资源；
- `Makefile`：构建入口。

## 构建

预览模式使用开源替代字体，适合 CI 或无 Windows 字体环境：

```bash
make template
```

输出：

```text
build/template.pdf
```

清理：

```bash
make clean
```

正式字体模式：

```bash
make template PREVIEW=false
```

如果字体不在系统字体目录，可以把自己合法持有的字体放到本地 `fonts/` 目录，然后编译：

```bash
make template PREVIEW=false FONT_PATH=fonts
```

## 正式字体需求

正式模式默认使用以下字体族名称：

- 宋体：`SimSun`
- 黑体：`SimHei`
- 仿宋：`FangSong`
- 华文新魏：`STXinwei`
- Times New Roman：`Times New Roman`
- 代码字体：`JetBrains Mono`

可以用下面命令检查 Typst 是否识别字体：

```bash
typst fonts | grep -E 'SimSun|SimHei|FangSong|STXinwei|Times New Roman|JetBrains Mono'
```

## 说明

`fonts/` 目录只作为本地字体放置位置，不随模板分发。若需要公开仓库，请确认字体授权后再自行决定是否提交。
