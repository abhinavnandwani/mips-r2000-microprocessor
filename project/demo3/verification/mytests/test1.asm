lbi r3, 5
slbi r3, 96
lbi r4, 12
slbi r4, 96
lbi r5, 37
slbi r5, 96

lbi r6, 20
lbi r7, 20

st r3, r3, 0
ld r7, r3, 4
st r3, r3, 8
ld r7, r3, 12
st r3, r3, 16
ld r7, r3, 20
st r3, r3, 24
ld r7, r3, 28

st r4, r4, 0
ld r7, r4, 4
st r4, r4, 8
ld r7, r4, 12
st r4, r4, 16
ld r7, r4, 20
st r4, r4, 24
ld r7, r4, 28

st r5, r5, 0
ld r7, r5, 4
st r5, r5, 8
ld r7, r5, 12
st r5, r5, 16
ld r7, r5, 20
st r5, r5, 24
ld r7, r5, 28

subi r6, r6, 1
beqz r6, 8

lbi r6, 20

st r6, r6, 0
ld r7, r6, 4
st r6, r6, 8
ld r7, r6, 12
st r6, r6, 16
ld r7, r6, 20
st r6, r6, 24
ld r7, r6, 28

st r7, r7, 0
ld r7, r7, 4
st r7, r7, 8
ld r7, r7, 12

st r3, r3, 0
ld r7, r3, 4
st r3, r3, 8
ld r7, r3, 12

st r4, r4, 0
ld r7, r4, 4
st r4, r4, 8
ld r7, r4, 12

st r5, r5, 0
ld r7, r5, 4
st r5, r5, 8
ld r7, r5, 12

subi r7, r7, 1
beqz r7, 8