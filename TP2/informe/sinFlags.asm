0000000000000000 <cropflip_c>:
   0:	55                   	push   rbp
   1:	48 89 e5             	mov    rbp,rsp
   4:	48 89 7d c8          	mov    QWORD PTR [rbp-0x38],rdi
   8:	48 89 75 c0          	mov    QWORD PTR [rbp-0x40],rsi
   c:	89 55 bc             	mov    DWORD PTR [rbp-0x44],edx
   f:	89 4d b8             	mov    DWORD PTR [rbp-0x48],ecx
  12:	44 89 45 b4          	mov    DWORD PTR [rbp-0x4c],r8d
  16:	44 89 4d b0          	mov    DWORD PTR [rbp-0x50],r9d
  1a:	8b 45 b4             	mov    eax,DWORD PTR [rbp-0x4c]
  1d:	48 63 d0             	movsxd rdx,eax
  20:	48 83 ea 01          	sub    rdx,0x1
  24:	48 89 55 d8          	mov    QWORD PTR [rbp-0x28],rdx
  28:	48 8b 55 c8          	mov    rdx,QWORD PTR [rbp-0x38]
  2c:	48 89 55 e0          	mov    QWORD PTR [rbp-0x20],rdx
  30:	8b 55 b0             	mov    edx,DWORD PTR [rbp-0x50]
  33:	48 63 ca             	movsxd rcx,edx
  36:	48 83 e9 01          	sub    rcx,0x1
  3a:	48 89 4d e8          	mov    QWORD PTR [rbp-0x18],rcx
  3e:	48 8b 4d c0          	mov    rcx,QWORD PTR [rbp-0x40]
  42:	48 89 4d f0          	mov    QWORD PTR [rbp-0x10],rcx
  46:	c7 45 f8 00 00 00 00 	mov    DWORD PTR [rbp-0x8],0x0
  4d:	eb 69                	jmp    b8 <cropflip_c+0xb8>
  4f:	c7 45 fc 00 00 00 00 	mov    DWORD PTR [rbp-0x4],0x0
  56:	eb 51                	jmp    a9 <cropflip_c+0xa9>
  58:	8b 4d f8             	mov    ecx,DWORD PTR [rbp-0x8]
  5b:	48 63 f1             	movsxd rsi,ecx
  5e:	48 63 ca             	movsxd rcx,edx
  61:	48 0f af ce          	imul   rcx,rsi
  65:	48 89 ce             	mov    rsi,rcx
  68:	48 03 75 f0          	add    rsi,QWORD PTR [rbp-0x10]
  6c:	8b 4d 28             	mov    ecx,DWORD PTR [rbp+0x28]
  6f:	8b 7d 18             	mov    edi,DWORD PTR [rbp+0x18]
  72:	01 f9                	add    ecx,edi
  74:	2b 4d f8             	sub    ecx,DWORD PTR [rbp-0x8]
  77:	83 e9 01             	sub    ecx,0x1
  7a:	48 63 f9             	movsxd rdi,ecx
  7d:	48 63 c8             	movsxd rcx,eax
  80:	48 0f af cf          	imul   rcx,rdi
  84:	48 89 cf             	mov    rdi,rcx
  87:	48 03 7d e0          	add    rdi,QWORD PTR [rbp-0x20]
  8b:	8b 4d 20             	mov    ecx,DWORD PTR [rbp+0x20]
  8e:	c1 e1 02             	shl    ecx,0x2
  91:	03 4d fc             	add    ecx,DWORD PTR [rbp-0x4]
  94:	48 63 c9             	movsxd rcx,ecx
  97:	0f b6 3c 0f          	movzx  edi,BYTE PTR [rdi+rcx*1]
  9b:	8b 4d fc             	mov    ecx,DWORD PTR [rbp-0x4]
  9e:	48 63 c9             	movsxd rcx,ecx
  a1:	40 88 3c 0e          	mov    BYTE PTR [rsi+rcx*1],dil
  a5:	83 45 fc 01          	add    DWORD PTR [rbp-0x4],0x1
  a9:	8b 4d 10             	mov    ecx,DWORD PTR [rbp+0x10]
  ac:	c1 e1 02             	shl    ecx,0x2
  af:	3b 4d fc             	cmp    ecx,DWORD PTR [rbp-0x4]
  b2:	7f a4                	jg     58 <cropflip_c+0x58>
  b4:	83 45 f8 01          	add    DWORD PTR [rbp-0x8],0x1
  b8:	8b 4d f8             	mov    ecx,DWORD PTR [rbp-0x8]
  bb:	3b 4d 18             	cmp    ecx,DWORD PTR [rbp+0x18]
  be:	7c 8f                	jl     4f <cropflip_c+0x4f>
  c0:	5d                   	pop    rbp
  c1:	c3                   	ret    