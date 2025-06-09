#  _PowerflowCalculator_ 项目简介

本项目是一个简单电力系统潮流/短路电流计算程序，潮流部分应用了经典的牛顿-拉夫逊算法，短路电流部分应用基本公式计算。整体程序使用 MATLAB 编写。`main` 分支主要是简单的 _CPU-based_ 计算版本，`GPUVersion` 分支是 _GPU-based_ 计算版本，供可能的计算优化使用。~~`App_basedmain`计划是基于同期较近的main程序转化的适宜于按照MATLAB APP发布或者按照独立程序发布的版本。~~(由于没有维护精力，该分支现已停止开发)可能会出现短期分支。

## 项目结构

`main`分支情况项目结构如下：

`PowerflowCalculator`：主程序目录
   - `src`：主程序文件夹
      - `main.m`：主程序入口
      - `DeviceInfo.m`：设备信息获取辅助函数
      - `PF_ReadData.m`：读取潮流数据
      - `PF_FormYmatrix`：构造潮流数据节点导纳矩阵
      - `PF_FormJacobi.m`：构造潮流计算用雅可比矩阵
      - `PF_CalculateDeltaPQ.m`：计算潮流计算用不平衡量
      - `PF_SolveCorrectionEquation`：计算潮流计算用雅可比矩阵修正量
      - `PF_CalculateBranchPowers`：计算潮流各类功率
      - `计算结果.txt`：计算结果文件 _(默认位置)_
      - `DeviceInfo.txt`：设备信息文件 _(默认位置)_
      - `SC_ReadData.m`：读取短路数据
      - `SC_FormYZmatrix.m`：构造短路数据节点导纳与阻抗矩阵
      - `SC_SinglePhase.m`：单相短路计算
      - `SC_TwoPhase.m`：两相短路计算
      - `SC_TwoPhase_Ground.m`：两相接地短路计算
      - `SC_ThreePhase.m`：三相短路计算
   - `PowerflowData`：潮流数据文件夹
   - `ShortCircuitData`：短路数据文件夹
   - `LICENSE` : 许可证文件
   - `.gitattributes` : Git属性文件
   - `.gitignore` : Git忽略文件
   - `README.md` : 项目说明文件

## 安装与运行

1. 克隆项目到本地：

```sh
git clone https://github.com/Snowlights2022/PowerflowCalculator.git
```
2. 打开 MATLAB 并导航到项目的目录：

```sh
cd path/to/PowerflowCalculator
```

3. 在MATLAB中运行主程序：
   
```MATLAB
main.m
```
4. 输入相关参数
   在图形化界面选择计算模式。之后：
   1. 在图形化界面选择潮流数据文件并输入迭代次数、精度参数后，程序会自动计算潮流，将**全部**节点电压、支路潮流情况输出到**命令行**，并默认输出节点电压到同目录文件 _计算结果.txt_ 中。同时输出 _DeviceInfo.txt_ 供查看设备运算能力信息。
   2.  在图形化界面选择短路数据文件并输入短路节点后，程序会自动计算近似短路网络（即忽略原有负荷和潮流分布的短路网络情况），将**全部**节点电压、支路电流情况与短路点电压电流输出到**命令行**，并输出到同目录文件 _计算结果.txt_ 中。同时输出 _DeviceInfo.txt_ 供查看设备运算能力信息使用。

## 许可证与版权说明

1. 本项目遵循**Apache-2.0**许可证，详细内容请查看 [LICENSE](LICENSE) 文件。
2. 本项目附带了来自[MatPower](https://github.com/MATPOWER/matpower/commit/6fba020d422a98f4176053c0478e62c4e8b9c6f5)的数据文件。MatPower的主要程序遵循**BSD-3-Clause**许可证，其[LICENSE](https://github.com/MATPOWER/matpower/commit/e6191418d34535cd5001ad8ea8c6cdb76d157926)说明了数据文件的许可模式。本项目在文件夹[PowerflowData](PowerflowData)内转存了一份 _MatPower_ 的[许可证](PowerflowData/LICENSE_data)供参考使用。
   
## 贡献
欢迎提交 _issues_ 和 _pull requests_ 来改进本项目！作为贡献者，您同意版权归属于该项目。如果您有兴趣，欢迎留下支持！

## 特别说明

1. 本项目的基本框架和计算函数是作者本科时参照`电力系统稳态分析（第四版） 陈珩编` `ISBN:978-7-5123-8172-8-01`教学内容，按照School of Electronical Engineering ,GuangxiUniversity要求完成的简单电力系统计算程序。潮流部分虽然经过[case4gs](PowerflowData/case4gs.m),[case5](PowerflowData/case5.m),[case30](PowerflowData/case30.m),[case118](PowerflowData/case118.m),[case2383wp](PowerflowData/case2383wp.m),[case9241](PowerflowData/case9241pegase.m)与[case13659](PowerflowData/case13659pegase.m)的验证并在1e-12左右的精度取得与参考结果相近的结果，但是作者无法保证计算结果的准确性，不对计算结果的准确性负责。短路部分存在较大的局限，详情请参考标记有**SC_**前缀的各个函数文件与注释。请在使用本程序前仔细阅读[许可证](LICENSE)。
2. 受限于作者能力水平，[PowerflowData](PowerflowData)中存在相当的用例无法执行潮流计算。