#### SecB2A, n = 3, k = 32

![image-20250311165819475](./B2An3k32_timing.png)

![image-20250311165826901](./B2An3k32_utils.png)

#### SecA2B, n=8, k=32

- SecA2B with parallelization

![image-20250312165934129](./A2Bn8k32_timing.png)

![image-20250312165830341](./A2Bn8k32_utils.png)

- SecA2B Baseline

![image-20250312171359886](./SecA2Bn8k32_bl_timing.png)

![image-20250312171601971](./SecA2Bn8k32_bl_utils.png)

- 总结

使用论文中提到的XC7A200TFFG1156-3 FPGA芯片

n=3时时钟周期设置为2.7ns，xdc仅约束了时钟周期（其中A2B模块的结果与原文的结果有差别，可能因为没设置其他约束）

n=8时比较了Python生成的电路与并行化的电路，并行化的电路延迟减小4个时钟周期（原电路为24个时钟周期），时钟周期设置为4.5ns；且由于CSA的位数减小，使用的LUT和Registers有所减少，但是所用资源均超出了FPGA芯片的资源

