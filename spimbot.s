#	Spimbot contest & lab
#
# 	TEAM NAME: 
#
#	Partners:
#		Erik Luo
#		Micheal Li
#		Erik Muro
#




.data

	# Lab 8 data
	

# constants
NULL = 0

# struct offsets
data = 0
left = 4
right = 8
node_size = 12


	# LAB 9 data

index:		.word 0
state:		.word 0
sorted_index:	.word -1

# syscall constants
PRINT_STRING = 4

# spimbot constants
VELOCITY = 0xffff0010
ANGLE = 0xffff0014
ANGLE_CONTROL = 0xffff0018
BOT_X = 0xffff0020
BOT_Y = 0xffff0024

TIMER = 0xffff001c
TIMER_MASK = 0x8000
TIMER_ACKNOWLEDGE = 0xffff006c
SCAN_MASK = 0x2000
SCAN_ACKNOWLEDGE = 0xffff0064
BONK_MASK = 0X1000
BONK_ACKNOWLEDGE = 0xffff0060



.text






#   LAB 7 Solutions and Implementation


# selectSmallest #######################################################
#
# arguments $a0: array of (i.e. pointer to) integers
#           $a1: size of array
#

selectSmallest:
	lw	$t0, 0($a0)		# min_array = numbers[0]
	li	$v0, 0			# min_location = 0
	li	$t1, 1			# i = 1

smallest_for:
	bge	$t1, $a1, smallest_swap	# !(i < array_size)
	mul	$t2, $t1, 4		# i * 4
	add	$t2, $a0, $t2		# &numbers[i]
	lw	$t2, 0($t2)		# numbers[i]
	bge	$t2, $t0, smallest_skip	# !(numbers[i] < min_array)
	move	$v0, $t1		# min_location = i
	move	$t0, $t2		# min_array = numbers[i]

smallest_skip:
	add	$t1, $t1, 1		# i++
	j	smallest_for

smallest_swap:
	lw	$t1, 0($a0)		# temp = numbers[0]
	sw	$t0, 0($a0)		# numbers[0] = min_array
	mul	$t2, $v0, 4		# min_location * 4
	add	$t2, $a0, $t2		# &numbers[min_location]
	sw	$t1, 0($t2)		# numbers[min_location] = temp
	jr	$ra			# return min_location (already in $v0)




# selectSort ##########################################################
#
# arguments $a0: array of integers
#           $a1: size of array

selectSort:	
	sub	$sp, $sp, 20
	sw	$ra, 0($sp)
	sw	$s0, 4($sp)
	sw	$s1, 8($sp)
	sw	$s2, 12($sp)
	sw	$s3, 16($sp)

	move	$s0, $a0		# numbers
	move	$s1, $a1		# array_size
	sub	$s2, $s1, 1		# array_size - 1
	li	$s3, 0			# i = 0

sort_for:
	bge	$s3, $s2, sort_done	# !(i < array_size - 1)
	mul	$t0, $s3, 4		# i * 4
	add	$a0, $s0, $t0		# &numbers[i]
	sub	$a1, $s1, $s3		# array_size - i
	jal	selectSmallest
	add	$s3, $s3, 1		# i++
	j	sort_for

sort_done:
	lw	$ra, 0($sp)
	lw	$s0, 4($sp)
	lw	$s1, 8($sp)
	lw	$s2, 12($sp)
	lw	$s3, 16($sp)
	add	$sp, $sp, 20
	jr	$ra




# calculateDistance ####################################################
#
# arguments $a0:    x1 coordinate
#           $a1:    y1 coordinate
#           $a2:    array of x coordinates
#	    $a3:    array of y coordinates
#           0($sp): array of distances (to be modified)
#           4($sp): size of array(s) 

calculateDistance:
	lw	$t0, 0($sp)		# distances
	lw	$t1, 4($sp)		# array_size
	li	$t2, 0			# i

distance_for:
	bge	$t2, $t1, distance_done	# !(i < array_size)
	mul	$t3, $t2, 4		# i * 4

	add	$t4, $a2, $t3		# &x_coords[i]
	lw	$t4, 0($t4)		# x_coords[i]
	sub	$t4, $a0, $t4		# x1 - x_coords[i]
	abs	$t4, $t4		# abs(x1 - x_coords[i])

	add	$t5, $a3, $t3		# &y_coords[i]
	lw	$t5, 0($t5)		# y_coords[i]
	sub	$t5, $a1, $t5		# y1 - y_coords[i]
	abs	$t5, $t5		# abs(y1 - y_coords[i])

	add	$t4, $t4, $t5		# abs(...) + abs(...)
	add	$t3, $t0, $t3		# &distances[i]
	sw	$t4, 0($t3)		# distances[i] = abs(...) + abs(...)
	add	$t2, $t2, 1		# i++
	j	distance_for

distance_done:
	jr	$ra




# calculatePath ########################################################
#
# arguments $a0:    spimbot x
#           $a1:    spimbot y
#           $a2:    array of x coordinates
#	    $a3:    array of y coordinates
#           0($sp): array of distances (to be modified)
#           4($sp): size of array(s) 

calculatePath:
	lw	$t0, 0($sp)		# distances
	lw	$t1, 4($sp)		# array_size

	sub	$sp, $sp, 20
	sw	$ra, 8($sp)
	sw	$a2, 12($sp)		# x_coords
	sw	$a3, 16($sp)		# y_coords

	sw	$t0, 0($sp)		# pass 5th argument on the stack
	sw	$t1, 4($sp)		# pass 6th argument on the stack
	jal	calculateDistance	# $a registers already hold correct values

	lw	$a0, 20($sp)		# distances
	lw	$a1, 24($sp)		# array_size
	jal	selectSmallest
	mul	$v0, $v0, 4		# min_index * 4

	lw	$a2, 12($sp)		# x_coords
	lw	$t0, 0($a2)		# temp = x_coords[0]
	add	$t1, $a2, $v0		# &x_coords[min_index]
	lw	$t2, 0($t1)		# x_coords[min_index]
	sw	$t2, 0($a2)		# x_coords[0] = x_coords[min_index]
	sw	$t0, 0($t1)		# x_coords[min_index] = temp

	lw	$a3, 16($sp)		# y_coords
	lw	$t0, 0($a3)		# temp = y_coords[0]
	add	$t1, $a3, $v0		# &y_coords[min_index]
	lw	$t2, 0($t1)		# y_coords[min_index]
	sw	$t2, 0($a3)		# y_coords[0] = y_coords[min_index]
	sw	$t0, 0($t1)		# y_coords[min_index] = temp

	lw	$ra, 8($sp)
	add	$sp, $sp, 20
	jr	$ra




























#   LAB 8 Solutions and Implementation



################################################################
# inorder_traversal - performs an in-order tree traversal
# $a0 - the address of the root node of the tree
################################################################

.globl inorder_traversal
inorder_traversal:
	beq	$a0, NULL, it_exit	# root == NULL (cleaner to not invert conditional)

	sub	$sp, $sp, 8
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)

	lw	$a0, left($a0)		# root->left
	jal	inorder_traversal

	lw	$a0, 4($sp)		# root (restore from stack)
	jal	print_node

	lw	$a0, 4($sp)		# root (restore from stack)
	lw	$a0, right($a0)		# root->right
	jal	inorder_traversal

	lw	$ra, 0($sp)
	add	$sp, $sp, 8

it_exit:
	jr	$ra


################################################################
# insert_value - inserts a value into the tree
# $a0 - a double pointer (a pointer to a pointer) to the root
# $a1 - the value to be inserted into the tree
################################################################

.globl insert_value
insert_value:
	lw	$t0, ($a0)		# *root
	bne	$t0, NULL, iv_not_null	# !(*root == NULL)

	sub	$sp, $sp, 8
	sw	$ra, 0($sp)
	sw	$a0, 4($sp)

	move	$a0, $a1		# x
	jal	generate_new_node
	lw	$a0, 4($sp)		# root (restore from stack)
	sw	$v0, ($a0)		# *root = generate_new_node(x)

	lw	$ra, 0($sp)
	add	$sp, $sp, 8
	jr	$ra

iv_not_null:
	lw	$t1, data($t0)		# (*root)->data
	bne	$t1, $a1, iv_left	# !((*root)->data == x)
	jr	$ra

iv_left:
	ble	$t1, $a1, iv_right	# !((*root)->data > x)
	la	$a0, left($t0)		# &((*root)->left)
	j	insert_value		# tail call

iv_right:
	la	$a0, right($t0)		# &((*root)->right)
	j	insert_value		# another tail call


################################################################
# delete_node - deletes a node from the tree
# $a0 - a double pointer to the node to be deleted
# don't worry about deallocating memory - consider a node to be
# deleted if nothing points to it
# consider this a helper function for remove_value
################################################################

.globl delete_node
delete_node:
	lw	$t0, ($a0)		# *to_delete
	lw	$t1, left($t0)		# (*to_delete)->left
	lw	$t2, right($t0)		# (*to_delete)->right

	bne	$t1, NULL, dn_right	# !((*to_delete)->left == NULL)
	sw	$t2, ($a0)		# *to_delete = (*to_delete)->right
	jr	$ra

dn_right:
	bne	$t2, NULL, dn_iop	# !((*to_delete)->right == NULL)
	sw	$t1, ($a0)		# *to_delete = (*to_delete)->left
	jr	$ra

dn_iop:
	la	$a0, left($t0)		# temp = &((*to_delete)->left)

dn_iop_loop:
	lw	$t1, ($a0)		# *temp
	lw	$t2, right($t1)		# (*temp)->right
	beq	$t2, NULL, dn_iop_found	# !((*temp)->right != NULL)
	la	$a0, right($t1)		# temp = &((*temp)->right)
	j	dn_iop_loop

dn_iop_found:
	lw	$t1, data($t1)		# (*temp)->data
	sw	$t1, data($t0)		# (*to_delete)->data = (*temp)->data
	j	delete_node		# yet another tail call


################################################################
# remove_value - removes a value from the tree
# $a0 - a double pointer to the root of the tree
# $a1 - the value to be removed
# this should find the node containing the value we want to
# remove, and then call delete_node
################################################################

.globl remove_value
remove_value:
	lw	$t0, ($a0)		# *root
	bne	$t0, NULL, rv_not_null	# !(*root == NULL)
	jr	$ra

rv_not_null:
	lw	$t1, data($t0)		# (*root)->data
	bne	$t1, $a1, rv_find_node	# !((*root)->data == x)
	j	delete_node_aux		# and another tail call

rv_find_node:
	ble	$t1, $a1, rv_go_right	# !((*root)->data > x)
	la	$a0, left($t0)		# &((*root)->left)
	j	remove_value		# and another one

rv_go_right:
	la	$a0, right($t0)		# &((*root)->right)
	j	remove_value		# and one more






# 	end of LAB 8

















#   LAB 9 Solutions and Implementation


# iteratePath ########################################################
#
# arguments: $a0:    spimbot x
#            $a1:    spimbot y
#            $a2:    x_coords[]
#            $a3:    y_coords[]
#            0($sp): array of distances (to be modified)
#            4($sp): size of array(s)

.globl iteratePath
iteratePath:
	sub	$sp, $sp, 40
	sw	$ra, 8($sp)
	sw	$s0, 12($sp)
	sw	$s1, 16($sp)
	sw	$s2, 20($sp)
	sw	$s3, 24($sp)
	sw	$s4, 28($sp)
	sw	$s5, 32($sp)
	sw	$s6, 36($sp)

	li	$t0, TIMER_MASK		# timer interrupt enable bit
	or	$t0, $t0, 1		# global interrupt enable
	mtc0	$t0, $12		# enable_timer_interrupts()

	lw	$t0, TIMER		# get_timer()
	add	$t0, $t0, 100		# get_timer() + 100
	sw	$t0, TIMER		# set_timer(...)

	move	$s0, $a2		# x_coords
	move	$s1, $a3		# y_coords
	lw	$s2, 40($sp)		# distances
	lw	$s3, 44($sp)		# array_size
	li	$s4, 0			# i = 0

ip_loop:
	bge	$s4, $s3, ip_end	# !(i < array_size)

	mul	$t0, $s4, 4		# i * 4
	add	$s5, $s0, $t0		# &x_coords[i]
	move	$a2, $s5
	add	$s6, $s1, $t0		# &y_coords[i]
	move	$a3, $s6
	add	$t0, $s2, $t0		# &distances[i]
	sw	$t0, 0($sp)		# pass 5th argument on stack
	sub	$t0, $s3, $s4		# array_size - i
	sw	$t0, 4($sp)		# pass 6th argument on stack
	jal	calculatePath		# $a0 and $a1 already hold correct values

	lw	$a0, 0($s5)		# x1 = x_coords[i]
	lw	$a1, 0($s6)		# y1 = y_coords[i]
	sw	$s4, sorted_index	# sorted_index = i
	add	$s4, $s4, 1		# i++
	j	ip_loop

ip_end:
	lw	$ra, 8($sp)
	lw	$s0, 12($sp)
	lw	$s1, 16($sp)
	lw	$s2, 20($sp)
	lw	$s3, 24($sp)
	lw	$s4, 28($sp)
	lw	$s5, 32($sp)
	lw	$s6, 36($sp)
	add	$sp, $sp, 40
	jr	$ra

	
.kdata
save0:	.word 0
save1:	.word 0
non_intrpt_str:	.asciiz "Non-interrupt exception\n"
unhandled_str:	.asciiz "Unhandled interrupt type\n"

.ktext 0x80000180
interrupt_handler:
	.set noat
	move	$k1, $at		# Save $at
	.set at
	sw	$a0, save0		# Get some free registers
	sw	$v0, save1		# by storing them to global variables

	mfc0 	$k0, $13		# Get Cause register
	srl 	$a0, $k0, 2		
	and 	$a0, $a0, 0xf		# ExcCode field
	bne 	$a0, 0, non_intrpt

interrupt_dispatch:			# Interrupt:
	mfc0 	$k0, $13		# Get Cause register, again
	beq	$k0, 0, done		# handled all outstanding interrupts

	and	$a0, $k0, SCAN_MASK	# is there a scanner interrupt?
	bne	$a0, 0, scanner_interrupt

	and	$a0, $k0, TIMER_MASK	# is there a timer interrupt?
	bne	$a0, 0, timer_interrupt

	and	$a0, $k0, BONK_MASK	# is there a bonk interrupt?
	bne	$a0, 0, bonk_interrupt

	li	$v0, PRINT_STRING	# Unhandled interrupt types
	la	$a0, unhandled_str
	syscall
	j	done

bonk_interrupt:
#implement

scanner_interrupt:
#implement

timer_interrupt:
		sw	$a0, TIMER_ACKNOWLEDGE	# acknowledge_timer_interrupt()

	ti_loop:
		lw	$a0, sorted_index
		lw	$v0, index
		bge	$a0, $v0, ti_align	# !(sorted_index < index)

		sw	$0, VELOCITY		# set_velocity(0)
		lw	$a0, TIMER		# get_timer()
		add	$a0, $a0, 400		# get_timer() + 400
		sw	$a0, TIMER		# set_timer(...)
		j	interrupt_dispatch	# return

	ti_align:
		mul	$k0, $v0, 4		# index * 4
		lw	$a0, state
		bne	$a0, 0, ti_align_y	# !(state == 0)

		lw	$a0, BOT_X		# current_x
		lw	$k0, X($k0)		# target_x
		sub	$k0, $k0, $a0		# diff
		abs	$a0, $k0		# abs_diff
		bge	$a0, 2, ti_face_x	# !(abs_diff < 2)

		li	$a0, 1
		sw	$a0, state		# state = 1
		j	ti_loop			# continue

	ti_face_x:
		ble	$k0, 0, ti_face_left	# !(diff > 0)
		li	$v0, 0			# new_angle = 0
		j	ti_move			# break

	ti_face_left:
		li	$v0, 180		# new_angle = 180
		j	ti_move			# break

	ti_align_y:
		lw	$a0, BOT_Y		# current_y
		lw	$k0, Y($k0)		# target_y
		sub	$k0, $k0, $a0		# diff
		abs	$a0, $k0		# abs_diff
		bge	$a0, 2, ti_face_y	# !(abs_diff < 2)

		sw	$zero, state		# state = 0
		add	$v0, $v0, 1		# index + 1
		sw	$v0, index		# index = index + 1
		j	ti_loop			# continue

	ti_face_y:
		ble	$k0, 0, ti_face_up	# !(diff > 0)
		li	$v0, 90			# new_angle = 90
		j	ti_move			# break

	ti_face_up:
		li	$v0, 270		# new_angle = 270

	ti_move:
		sw	$v0, ANGLE		# new_angle
		li	$v0, 1
		sw	$v0, ANGLE_CONTROL	# set_absolute_angle(new_angle)
		li	$v0, 10
		sw	$v0, VELOCITY		# set_velocity(10)
		lw	$v0, TIMER		# get_timer()
		mul	$a0, $a0, 400		# abs_diff * 400
		add	$v0, $v0, $a0		# get_timer() + abs_diff * 400
		sw	$v0, TIMER		# set_timer(...)
		j	interrupt_dispatch

non_intrpt:				# was some non-interrupt
	li	$v0, PRINT_STRING			
	la	$a0, non_intrpt_str
	syscall				# print out an error message
	j	done

done:
	lw	$a0, save0
	lw	$v0, save1
	.set noat
	move	$at, $k1		# Restore $at
	.set at
	eret





# end of LAB 9