#import "../hit-opening.typ": hit-opening, hit-three-line-table

#let preview = sys.inputs.at("preview", default: "true") == "true"

#show: hit-opening.with(
  preview: preview,
  reporttype: "design",
  blank-after-cover: false,
  title: [一个用于检查模板排版的示例课题],
  author: [张三],
  student-id: [2023123456],
  affiliation: [深圳校区计算机科学与技术学院],
  subject: [计算机科学与技术],
  supervisor: [李四 教授],
  date: [2026 年 10 月],
)

= 课题背景及研究的目的和意义

== 课题背景

这是模板的示例正文。正文可以正常包含中文、English、数字 123，以及顺序编码制参考文献引用。POSIX 标准可作为系统接口定义的一个示例来源#cite(<posix2024>)，xv6 则可作为教学操作系统的示例来源#cite(<xv6>)。

== 研究的目的和意义

这一节用于检查二级标题、正文首行缩进、页眉页脚、页码以及引用上标是否正常。

= 主要研究内容及研究方案

== 模块边界

三级标题用于检查目录层级和正文标题样式。Theseus 的工作可以作为操作系统模块与状态边界研究的示例引用#cite(<theseus>)。

=== 代码样式

块级代码使用白底、方角与细边框；行内代码保持无边框，例如 `execve`。

```rust
fn main() {
    println!("hello, kernel");
}
```

=== 插图

#figure(
  image("assets/thunder.svg", width: 75%),
  caption: [示例程序运行结果],
) <thunder>

如 @thunder 所示，图片、图题和编号均由模板统一处理。

== 进度安排

#figure(
  hit-three-line-table(
    (1fr, 2fr, 2fr),
    ([时间], [主要工作], [阶段成果]),
    (
      ([2026.10], [完成需求分析和总体设计], [形成设计文档]),
      ([2026.11], [实现基础模块并建立测试], [得到可运行原型]),
      ([2026.12], [集成并整理实验结果], [完成阶段总结]),
    ),
  ),
  caption: [示例进度安排],
) <tab-example>

如 @tab-example 所示，表格可以通过标签在正文中引用。

= 参考文献示例

#heading(level: 1, numbering: none, outlined: true)[参考文献]
#v(13.66pt)
#block[
  #set text(top-edge: 1.00625em, bottom-edge: -0.43125em)
  #set par(leading: 0pt, spacing: 0pt, first-line-indent: 0pt)
  #bibliography(
    "references.bib",
    title: none,
    style: "../hit-gb7714.csl",
  )
]
