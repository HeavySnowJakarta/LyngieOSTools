[bits 32]
COLOR_DIALOG_BACKGRUND equ 0x7bbbf5
COLOR_TITLE_BAR equ 0x5b9bd5;0x00d2deef
COLOR_TITLE_BAR_FOCUS equ 0x3b7bb5   ;深色 
COLOR_TITLE_BAR_UNFOCUS equ 0x00d2deef
COLOR_TEXT_BOX_BACK_GROUND equ 0x00050505   ;黑色的背景
COLOR_TEXT_STRING equ 0x00f0f0f0            ;白色的字体背景

;此程序为标准的开发程序格式，适用于命令行。
program_length dd program_end    ;程序大小
jmp start                        ;程序入口，可修改入口
	;可以在这里放上你的数据或者可执行代码。
start:  
	;TODO:可以在此处开始放上初始化代码。如果为空，则默认命令行界面。 
	mov eax,widget_start
	mov edi,0x10           ;设置页面
	int 0x31                     ;调用系统图形API
	ret 
	
on_mouse_left_button_down_handler:
	mov eax,widget_picture_desk_back_ground_address
	mov edi,0x1e                 ;获取得到画布，内存地址保存在ebx中
	int 0x31

	mov ecx,4096                 ;从（0，0）像素开始写入1024个像素的颜色值。
	.set_color:
		mov dword [ds:ebx],COLOR_TEXT_STRING   ;字体白
		add ebx,0x04 
		loop .set_color
	ret 

on_mouse_right_button_down_handler:
	mov edx,0x0012_c000			;需要申请的内存空间，对应640X480(个像素)X4(每像素4字节)
	mov edi,0x1c                 ;申请一段内存，作为canvas
	int 0x31
	test ebx,0xFFFF_FFFF
		jz .exit_memory_allocate_failed


	mov eax,widget_picture_desk_back_ground_address        ;需要设置的图片控件
	mov ecx,0x0280_01e0			;设置画布的分辨率为640x480
	mov edi,0x1f                ;设置画布，内存地址保存在ebx中
	int 0x31
	test edi,0xFFFF_FFFF
		jnz .exit_set_canvas_error    ;不为0则表示画布设置失败

	;开始往画布中设置像素颜色
	mov ecx,4096                 ;从（0，0）像素开始写入1024个像素的颜色值。
	.set_color:
		mov dword [ds:ebx],0x00_FF_00_ff   ;RGB,紫色
		add ebx,0x04 
		loop .set_color

	.exit_memory_allocate_failed:
	.exit_set_canvas_error:
		ret
;-------------------------------------------------------------
;数据区定义
DATA:
	
	;---------------------------------------------------------
	;页面定义
		page_start dd 0x0000_0000             ;第一个必须为 0
	widget_start 	dd widget_picture_desk_back_ground_address

		dd 0x0000_0000 
		dd 0x0000_0000
		page_end dd 0x0000_0000           ;用户页面结束

	;---------------------------------------------------------
	;图片控件定义
	widget_picture_desk_back_ground_address:
		.draw_location_y dw 0x0000
		.draw_location_x dw 0x0000
		.height   dw 480                 ;宽度，也就是上下
	    .width  dw 640                 ;长度，也就是左右
	    .back_ground_color  dd 0x005b9bd5    ;控件背景颜色
	    .boarder_width  dw 0x0000       ;边框大小，以像素为单位
	    .boarder_color  dd 0x0000_0000  ;边框颜色
	    .alpha  dw 0x0000               ;透明度
	    .visibility  dw 0xffff          ;是否可见，为0则不可见

	    ;交互属性
	    .on_mouse_left_button_down_handler  dd on_mouse_left_button_down_handler  ;需要跳转执行的地址，注意只能跳转到当前的应用中
	    .on_mouse_left_button_up_handler  dd 0x0000_0000   ;鼠标左键双击事件执行跳转
	    .on_mouse_right_button_down_handler  dd on_mouse_right_button_down_handler
	    .on_mouse_right_button_up_handler  dd 0x0000_0000
	    .on_mouse_wheel_roll_down_handler  dd 0x0000_0000       ;鼠标滚轮向上滚动
	    .on_mouse_wheel_roll_up_handler  dd 0x0000_0000     ;鼠标滚轮向下滚动
	    .on_mouse_wheel_button_down_handler dd 0x0000_0000 ;鼠标中键按下
	    .on_mouse_wheel_button_up_handler dd 0x0000_0000  ;鼠标中键释放
	    .on_mouse_cursor_moved_on_handler  dd 0x0000_0000           ;鼠标在上面
	    .on_mouse_cursor_moved_off_handler  dd 0x0000_0000    ;鼠标移走事件
	    .on_mouse_cursor_moved_handler  dd 0x0000_0000        ;鼠标在控件上的移动事件
	    .on_keyboard_key_down_handler  dd 0x0000_0000            ;键盘输入事件
	    .on_keyboard_key_up_handler  dd 0x0000_0000           ;键盘释放事件
	    .widget_state_flag  dw 0x0002                         ;控件当前的状态等，包括是否获得焦点，0x02表示自动刷新到下一行

	    ;控件本身的属性
	    .widget_id  dd 0x0000_0000                    ;控件ID 用来第一次绘制的时候写入控件ID
	    .widget_type  dw 0x02                      ;控件类型
	    .data_input_source  dd .text_string            ;数据源的输入
	    .data_output_target  dd 0x0000_0000           ;数据的输出位置

	    ;edit_text_box控件特有的属性
	    .start_draw_location_x  dw 0x0000             ;文本的起始绘制位置。
	    .start_draw_location_y  dw 0x0000             ;文本的起始绘制位置，Y轴
	    .current_text_cursor_loc_y  dw 0x0000         ;当前光标的位置y轴。
	    .current_cursor_offset_in_text  dd 0x0000_0000   ;当前光标在文本中的位置。
	    .last_start_show_offset_in_text  dd 0x0000_0000   ;上一个起始显示的字符串位置。
	                                                    ;当文本超过了一个页面的时候，自动给它新申请一段内存地址用于存放连续的内容
	    .text_length  dd 0x0000_0000                   ;字符串长度超过4096个字节的时候自动申请另外一段连续的内存空间给它

	    .text_string:
			;字符串的显示属性
	        .string_print_loc_scale dd 0x0000_0000        ;字符串的显示位置，一般是父控件的相对位置。形式为xxxx_yyyy
	        .string_text_size dd 0x0008_0010              ;字体大小，单位为像素
	        .string_text_color dd 0x00ff_ffff             ;字体的颜色
	        
	        .string_text_print_start dd 0x0000_0000       ;字符串的起始显示位置，通过变换位置来刷新显示
	        .string_edit_cursor dd 0x0000_00ff       ;字符串的可编辑指针，从这里往后面添加字符

	        ;字符串本身的属性
	        .string_start_address dd .string_buffer
	        .string_current_letters dd 0x0000_0003   ;字符串当前的字符长度,13个字节
	        .string_buffer_length dd 0x0000_0001   ;4096个字节的长度  ;超过了之后就需要重新申请，并刷新字符串
	
			.string_buffer db 'desktop.bmp',0
				times 16-($-.string_buffer) db 0

program_end: