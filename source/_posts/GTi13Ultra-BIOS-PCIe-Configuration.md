---
title: 零刻GTi13Ultra进入BIOS切换显卡PCIe通道
mathjax: false
date: 2026-03-06 05:42:02
updated:
permalink:
tags:
- GPU
- BIOS
- PCIe
- eGPU
categories:
description: 记录零刻 GTi13 Ultra 在 BIOS 中切换 PCIe 通道速率的步骤与注意事项，并补充 30/40 系显卡在 3.0x8 与 4.0x8 下的兼容性经验。省流：开机 Del 进 BIOS，按 Chipset -> SA -> PCI Express Root Port 2 修改 PCIe Speed，40 系优先 3.0x8，30 系可尝试 4.0x8。
photo: https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20260306-054350-44693.png
---

## Solution

开机按Del键，进入bois

依次进入：

- Chipset
- System Agent (SA) Configuration
- PCI Express Configuration
- PCI Express Root port 2

修改选项 `PCIe Speed`，默认为Auto。

修改后，按 `F4` 保存并退出。

## Tips

支持跑3.0x8和4.0x8，但是**听说**对于40系显卡由于不明原因，不能跑在4.0下，只能退而求其次跑3.0x8。30系显卡反而支持4.0x8，享受两倍带宽。

所以，其实更建议用30系的卡外接？

## Reference

[GTi13 Ultra BIOS设置 | 零刻知识库](https://doc.bee-link.com.cn/books/gti13-ultra-bios)

[切换PCIE通道速度 | 零刻知识库](https://doc.bee-link.com.cn/books/gti13-ultra-bios/page/pcie)