.data
cities:
.word   0
.word   0
.word   8
.word   6
.word   2
.word   4
.word   6
.word   7
.word   1
.word   3
.word   9
.word   4
.word   2
.word   3

min_dist:  .float    987654321.0  # Maximum value
dist:      .space 196  # double ditance[7][7]
optimal:   .space 28   # int optimal[7]
path:      .space 32   # int path[8]

$LC0: .asciiz  "Distance : "
$LC1 :.asciiz  "Path is : "
space :.asciiz  " "
enter: .asciiz "\n"

.text
main:
    li   $s5, 0   #i
    j   cal_dist
    nop

cal_dist:   # to caculate distance between cities
    addi   $s5, $s5, 1
    nop
   
    beq    $s5, 7, call_tsp
    nop

    li     $s6, 0
    nop

cal_dist_loop:   # the loop for cal_dist
    bgt    $s6, $s5, cal_dist
    nop
    la     $t0, cities   #cities t0
    nop
      
    sll    $t1, $s5, 3
    addu   $t2, $t1, $t0
    nop
      
    lw     $t3, 0($t2)   #cities[i].x = t3
    lw     $t5, 4($t2)
    nop
      
    sll    $t1, $s6, 3  
    addu   $t2, $t1, $t0
    lw     $t4, 0($t2)   #cities[j].x = t4
    lw     $t6, 4($t2)
    nop
  
    subu   $t1, $t3, $t4   #sub
    subu   $t2, $t5, $t6   #sub
    nop
  
    mult   $t1, $t1
    mflo   $2
    mult   $t2, $t2
    mflo   $3
    addu   $2, $2, $3
    mtc1   $2, $f0
    nop
      
    cvt.s.w  $f0, $f0
    mov.s    $f12, $f0
    sqrt.s   $f0, $f12    # calculate sqrt
    nop

    la    $t0, dist          # $t0 = &dist
    mul   $t1, $s5, 7        # col processing; $t1 = i * 7
    add   $t1, $t1, $s6      # row proceesing; $ti = i * 7 + j
    sll   $t1, $t1, 2        # address processing; size of float
    add   $t0, $t0, $t1      # $t0 = &dist[i][j]
    s.s   $f0, 0($t0)        # $f4 = dist[i][j]
    nop

    la    $t0, dist
    mul   $t1, $s6, 7        # col processing; $t1 = j * 7
    add   $t1, $t1, $s5      # row proceesing; $ti = j * 7 + i
    sll   $t1, $t1, 2        # address processing; size of float
    add   $t0, $t0, $t1      # $t0 = &dist[j][i]
    s.s   $f0,  0($t0)
    nop
    addi  $s6, $s6, 1
    j      cal_dist_loop
    nop

call_tsp:   # set the first and last point of path and call tsp
    li      $t0, 1
    la      $t1, path
    sw      $t0, 0($t1)          # path[0] = 1
    sw      $t0, 28($t1)         # path[7] = 1   
    la      $t2, optimal
    sw      $t0, 0($t2)          # optimal[0] = 1

    li      $a0, 0               # cur
    li      $a1, 0               # count
    li      $a2, 1               # visited
    mfc1    $zero, $f1           # sum
    jal     tsp                  # call tsp
    nop

exit_program:   # exit the program
    la      $a0, $LC0
    li      $v0, 4
    syscall

    lwc1     $f12, min_dist
    li       $v0, 2
    syscall

    nop
    la      $a0, enter
    li      $v0, 4
    syscall
    nop

    jal     print_result
    nop
    
    li      $v0, 10
    syscall

print_result:  # to print path
    la      $a0, $LC1
    li      $v0, 4
    syscall

    la       $t0, path
    li       $t1, 0      # i = 0
   
print_result_loop:
    beq      $t1, 8, print_result_end   # if i >= 8 then print_path_tsp_end
    sll      $t2, $t1, 2      
    add      $t2, $t0, $t2   # dist[i]
  
    lw       $a0, 0($t2)      # $a0 = dist[i]
    li       $v0, 1         # print integer
    syscall
    nop
        
    la      $a0, space     
    li      $v0, 4
    syscall
    nop
        
    addiu   $t1, $t1, 1      # i++
    j       print_result_loop
    nop

print_result_end:
    jr      $ra            # jump to $ra
    nop

# $a0: current position, $a1: count, $a2: visited(bit masking), $f1: sum of distance, $s0: index
tsp:  # Find optimal tsp path; use tail recursion
    beq   $a2, 127, tsp_end   # visit all cities then end tsp (127 == (1 << 7) - 1)
    nop

    li   $s0, 0 
 
tsp_loop:  # for each cities
	addi   $s0, $s0, 1               # ++k
    beq      $s0, 7, tsp_loop_end    # condition for stopping loop
    nop

    # If we visit the city
    li      $t1, 1
    sllv   $s1, $t1, $s0     # $s1 (= 1 << k) 
    and      $t1, $a2, $s1
    beq      $t1, $s1, tsp_loop

    # If the city is same with current position
    beq      $a0, $s0, tsp_loop
    nop
            
    la      $t0, dist          # $t0 = &dist
    mul      $t1, $a0, 7       # col processing; $t1 = cur * 7
    add      $t1, $t1, $s0     # row proceesing; $ti = cur * 7 + k
    sll      $t1, $t1, 2       # address processing; size of float
    add      $t0, $t0, $t1     # $t0 = &dist[cur][k]
    l.s      $f3, 0($t0)       # $f3 = dist[cur][k]
    add.s   $f0, $f3, $f1      # $f0 = sum + dist[cur][k]

    la      $v0, min_dist
    l.s      $f2, 0($v0)         # $f2 = min_dist
      
    c.lt.s   $f2, $f0         # if sum + dist[cur][k] > min_dist then tsp_loop
    bc1t   tsp_loop
    nop
       
    # 3 people team condition: check that 3rd should be visited before 7th city
    addi   $s2, $s0, 1   # $s2 (= k + 1)
    bne      $s2, 7, recursive_call 
    andi   $v1, $a2, 4   # $v1 = visited & 1 << (3-1)
    bne      $v1, 0, recursive_call
    j tsp_loop
    nop

recursive_call: 
    addi   $s3, $a1, 1         # $s3 (= count + 1)
    sll      $t8, $s3, 2   
    la      $t1, optimal   
    add      $t1, $t8, $t1  
    sw      $s2, 0($t1)         

    # save register before call tsp
    addi   $sp, $sp, -24
    sw      $ra, 20($sp)
    sw      $a0, 16($sp)
    sw      $a1, 12($sp)
    sw      $a2, 8($sp)
    s.s      $f1, 4($sp)  
    sw      $s0, 0($sp)      
      
    # update argument
    move   $a0, $s0     
    move   $a1, $s3     
    or      $a2, $a2, $s1
	
	mov.s   $f1, $f0      
    jal      tsp         # recursive
    nop
     
    # reposit stack 
    lw      $s0, 0($sp)
    l.s     $f1, 4($sp)
    lw      $a2, 8($sp)
    lw      $a1, 12($sp)
    lw      $a0, 16($sp)
    lw      $ra, 20($sp)
    addi    $sp, $sp, 24
      
    j      tsp_loop               # jump to tsp_for
    nop

tsp_end:
    la      $t0, dist
    mul     $t1, $a0, 7
    sll     $t1, $t1, 2      
    add     $t0, $t0, $t1         # $t0 = &dist[cur][0]
    l.s     $f4, 0($t0)           # $f4 = dist[cur][0]
    add.s   $f8, $f1, $f4         # sum += dist[cur][0]
    la      $t9, min_dist         # $t9 = &min_dist
    l.s     $f6, 0($t9)           # $f6 = min_dist
    c.lt.s  $f8, $f6              # if sum < min_dist 
    bc1t   update                 # then goto update
    nop
        
    jr      $ra
    nop

update: 
    s.s     $f8, 0($t9)          # min_dist = sum
    addi    $sp, $sp, -4
    sw      $ra, 0($sp)
    jal     update_path
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    nop
   
tsp_loop_end:
   jr      $ra
   nop

update_path:
    li      $v0, 0   # i

update_path_loop:
    bge     $v0, 7, update_path_end
    sll     $v1, $v0, 2
    la      $t1, optimal
    add     $t1, $t1, $v1

    lw      $t2, 0($t1)
    la      $t3, path
    add     $t3, $t3, $v1
    sw      $t2, 0($t3)

    addiu   $v0, $v0, 1
    b         update_path_loop
    nop

update_path_end:
    jr     $ra
    nop