---
title: qwen3系列模型个人简评
mathjax: true
date: 2025-04-29 22:15:50
tags:
- LLM
categories:
description: "你知道的，我一直是qwen的粉丝；<br>至于ds，在r2出来之前我祝他好运。"
photos: https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250429-222031-82845.png
---

# qwen3系列模型个人简评

**你知道的，我一直是qwen的粉丝；**

**至于ds，在r2出来之前我祝他好运。**

个人本地部署下来，几个感触：

坏消息：

- 没有在测试中感受到任何突破同尺寸模型能力的情况：多少b的大小，就有多少b的能力。比如r1-671b，只有235b能抗衡；

好消息：

- 原生支持格式化输出（没测试）

- 支持MCP（没测试）本地部署+mcp想想就刺激

- 超多尺寸，更有超多量化版本，任君选择

- 自由控制/切换enanle_thinking。本地部署的话不需要同时开两个模型/两个模型来回切换了

- 原生思考模型，而非之前r1蒸馏出来的那种有些残缺的模型（体验非常不好）

- MoE架构，速度非常快：【非正式测评】lmstidio中qwen3-30b-a3b Q3_K_L(13.58GB)拉满32k上下文需要24G显存，在双卡（4060l+4070tis）上跑，在低速卡耽误整体速度的情况下依然能跑到35t/s的输出；4k上下文时占14G不到，单4070tis速度约84t/s（对比：qwen3-14b Q4_K_M(8.38GB)拉满上下文，双卡速度约31t/s；4k上下文时占11G不到，单4070tis速度约49t/s）

- 幻觉率肉眼可观的比r1低多了！一旦问起“为什么”类型的问题，r1各种编参数、编专有名词。可以看看下面分别问r1和qwen3-14b“为什么xxx(你)模型幻觉率这么高”的不同回答，可以发现r1确实也有分析，但是分析到一半就开始编造参数了。（想想要是有人敢在论文里直接复制r1编出来的东西那就完蛋了）相比之下，qwen3-14b主要还是从各个角度找可能的原因与分析。同时，这也能体现原生（非蒸馏）小型推理模型的优点。

    ![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250429-221307-10001.png)

    ![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250429-221326-10001.png)

- 和人聊天效果比r1更好，更像是“有灵魂”（个人感觉）

    ![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250429-221346-10001.png)

    ![](https://vanilla-picture-with-picgo.oss-cn-shenzhen.aliyuncs.com/img-from-OSS-uploader/20250429-221401-10001.png)