PagerView
=========

该类用于实现横向Pager效果
相对于UIScrollView有以下优点

  - 可以指定PageSize
  - 可以像TableView一样重用cell

相对于SwipeView有以下优点

  - 可以兼容autoLayout
  - 滚动动画没做任何trick，完全使用UIScrollViewDelegate实现，性能和效果都更好

该类数据接口都由block实现
