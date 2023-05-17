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

	mov dword esi,[ds:ebx+0x10]  ;指向参数3，也就是传递的字符串
	mov dword ecx,[ds:esi]       ;得到传递的字符串参数的长度
	test ecx,0xFFFF_FFFF
		jz .exit_normal
	add esi,0x04
	mov edi,0x1a			;加载这个文件
	int 0x31
 
	test edi,0xFFFF_FFFF
		jnz .cannot_open_this_file

	push eax  
	;打开成功的话，首先要设置文件名称到名称文本框
	mov eax,default_file_name_edit_text_box
	mov edi,0x11 
	int 0x31
	pop eax 
	;然后将文件内容设置到文本编辑框的edit_text_box上。edx返回了加载的文件大小
	mov ecx,edx             ;字符串长度
	mov esi,eax				;得到打开的内存地址  
	add esi,0x04 
	mov eax,default_edit_text_box
	mov edi,0x11 
	int 0x31
.exit_normal:
	ret 

	.cannot_open_this_file:
	;获取字符串参数传递。如果有字符串则按照文件名称打开。如果没有则继续。 
	.show_error_diolog:
    	mov esi,string_error_can_not_open_file
    	mov ecx,0x0000_00ff
    	mov edi,0x16 
		int 0x31
    	ret

;点击打开文件按钮
on_mouse_left_button_down_handler_open:
		mov eax,default_file_name_edit_text_box
		mov edi,0x14
		int 0x31      ;获取文件名称字符串
		add esi,0x04  ;跳过大小字节。

		mov edi,0x1a  ;open file by name 
    	int 0x31      ;根据名称保存文件。
    	test edi,0xFFFF_FFFF
    		jnz .show_error_diolog

    	mov esi,eax
    	add esi,0x04 
    	mov ecx,edx 
		mov eax,default_edit_text_box       ;获取输入内容
		mov edi,0x11
		int 0x31      ;获取文件名称字符串
		
    	ret 
    .show_error_diolog:
    	mov esi,string_error_can_not_open_file
    	mov ecx,0x0000_00ff
    	mov edi,0x16 
		int 0x31
    	ret


;当鼠标从文本框中移除之后，显示open save 和文件名称等3个控件。
on_mouse_cursor_moved_off_handler_default_edit_text_box:
		mov dword eax,[ds:default_edit_text_box.draw_location_y]
		cmp ax,0x10 
			jge .exit_already_show        ;大于或等于

		mov dword ecx,0x08
	.draw_animation: 
		mov dword eax,[ds:default_edit_text_box.draw_location_y]    ;得到绘制位置
		add ax,0x02
		mov dword [ds:default_edit_text_box.draw_location_y],eax

		mov dword eax,[ds:default_open_button.draw_location_y]    ;得到绘制位置
		add ax,0x02
		mov dword [ds:default_open_button.draw_location_y],eax

		mov dword eax,[ds:default_save_button.draw_location_y]    ;得到绘制位置
		add ax,0x02
		mov dword [ds:default_save_button.draw_location_y],eax 
		
		mov dword eax,[ds:default_file_name_edit_text_box.draw_location_y]    ;得到绘制位置
		add ax,0x02
		mov dword [ds:default_file_name_edit_text_box.draw_location_y],eax 
		
		mov eax,40           ;休眠40毫秒
		mov edi,0x15
		int 0x31
		loop .draw_animation
	.exit_already_show:
		ret 

on_mouse_cursor_moved_handler_default_edit_text_box:
		mov dword eax,[ds:default_edit_text_box.draw_location_y]
		mov ecx,0x01 
		cmp cx,ax  
			jg .exit_already_hide        ;大于或等于

		mov dword ecx,0x08
	.draw_animation: 
		mov dword eax,[ds:default_edit_text_box.draw_location_y]    ;得到绘制位置
		sub ax,0x02
		mov dword [ds:default_edit_text_box.draw_location_y],eax 
		
		mov dword eax,[ds:default_open_button.draw_location_y]    ;得到绘制位置
		sub ax,0x02
		mov dword [ds:default_open_button.draw_location_y],eax 
		
		mov dword eax,[ds:default_save_button.draw_location_y]    ;得到绘制位置
		sub ax,0x02
		mov dword [ds:default_save_button.draw_location_y],eax 
		
		mov dword eax,[ds:default_file_name_edit_text_box.draw_location_y]    ;得到绘制位置
		sub ax,0x02
		mov dword [ds:default_file_name_edit_text_box.draw_location_y],eax 
		
		mov eax,40           ;休眠40毫秒
		mov edi,0x15
		int 0x31
		loop .draw_animation

	.exit_already_hide:
		ret

;点击关闭按钮
on_mouse_left_button_down_handler_save:
		mov eax,default_edit_text_box       ;获取输入内容
		mov edi,0x14
		int 0x31      ;获取文件名称字符串
		add esi,0x04 

		push ecx 
		push esi      ;保存字符串名称
		mov eax,default_file_name_edit_text_box
		mov edi,0x14
		int 0x31      ;获取文件名称字符串
		add esi,0x04  ;跳过大小字节。
    	pop eax 
    	pop edx  

    	mov edi,0x1b 
    	int 0x31      ;根据名称保存文件。
    	test edi,0xFFFF_FFFF
    		jnz .show_error_diolog
    	ret 
    .show_error_diolog:
    	mov esi,string_error_can_not_save_file
    	mov ecx,0x0000_00ff
    	mov edi,0x16 
		int 0x31
    	mov edi,0x16 
		int 0x31
    	ret


on_mouse_left_button_down_handler:
	mov dword esi,0x12c0_0000
	mov dword [ds:esi],0x0000ffff
	mov eax,widget_picture_desk_back_ground_address
	mov edi,0x1e                 ;获取得到画布，结果保存在ebx中
	int 0x31
	mov ecx,307000
	.set_color:
		mov dword [ds:ebx],COLOR_TEXT_STRING  
		add ebx,0x04 
		loop .set_color
	ret 

	mov eax,default_edit_text_box
	mov esi,string_mouse_left_button_down
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31               
	ret

on_mouse_left_button_up_handler:
	mov eax,default_edit_text_box
	mov esi,string_mouse_left_button_up
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret 

on_mouse_right_button_down_handler:
	mov eax,widget_picture_desk_back_ground_address
	mov edi,0x1e                 ;获取得到画布，结果保存在ebx中
	int 0x31

	mov ecx,2048
	.set_color:
		mov dword [ds:ebx],COLOR_TEXT_STRING  
		add ebx,0x04 
		loop .set_color
	ret 

	mov eax,default_edit_text_box
	mov esi,string_mouse_right_button_down
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret

on_mouse_right_button_up_handler:
	mov eax,default_edit_text_box
	mov esi,string_mouse_right_button_up
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret

on_mouse_wheel_roll_down_handler:
	mov eax,default_edit_text_box
	mov esi,string_mouse_wheel_scroll_down
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret
on_mouse_wheel_roll_up_handler:
	mov eax,default_edit_text_box
	mov esi,string_mouse_wheel_scroll_up
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret

on_mouse_wheel_button_down_handler:
	mov eax,default_edit_text_box
	mov esi,string_mouse_middle_button_down
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret

on_mouse_wheel_button_up_handler: 
	mov eax,default_edit_text_box
	mov esi,string_mouse_middle_button_up
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret

on_mouse_cursor_moved_on_handler:  
	mov eax,default_edit_text_box
	mov esi,string_mouse_cursor_moved_on_event
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret

on_mouse_cursor_moved_off_handler: 
	mov eax,default_edit_text_box
	mov esi,string_mouse_cursor_moved_off_event
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret

on_mouse_cursor_moved_handler:
	mov eax,default_edit_text_box
	mov esi,string_mouse_cursor_moved_event
	mov ecx,0xff 
	mov edi,0x11                 ;设置控件字符串
	int 0x31
	ret
  
on_keyboard_key_down_handler: 
	push edi  
	push esi  
	mov esi,string_this_is_a_dialog_test
	mov edi,0x16 
	;int 0x31    
	pop esi 
	pop edi 
	ret 

on_keyboard_key_up_handler: 
ret

show_dialog:
	push edi  
	push esi  
	mov esi,string_this_is_a_dialog_test
	mov edi,0x16 
	int 0x31    
	pop esi 
	pop edi 
	ret
	 
create_file:
	
	mov esi,string_test4
	mov ecx,5                   ;5个字节名称
	mov edi,0x17                ;新建文件夹
	int 0x31   
	ret
	
;-------------------------------------------------------------
;数据区定义
DATA:
	string_error_can_not_save_file db 'Failed to save this file.',0
	string_error_can_not_open_file db 'Failed to open this file.',0

	string_mouse_left_button_up db 'mouse left button up event.',0 
	string_mouse_left_button_down db 'mouse left button down event.',0
	
	string_mouse_right_button_up db 'mouse right button up event.',0 
	string_mouse_right_button_down db 'mouse right button down event.',0

	string_mouse_middle_button_up db 'mouse middle button up event.',0
	string_mouse_middle_button_down db 'mouse middle button down event.',0

	string_mouse_wheel_scroll_up db 'mouse wheel scroll up event.',0
	string_mouse_wheel_scroll_down db 'mouse wheel scroll down event.',0

	string_mouse_cursor_moved_on_event db 'mouse cusor moved on event.',0
	string_mouse_cursor_moved_off_event db 'mouse cusor moved off event.',0

	string_mouse_cursor_moved_event db 'mouse cursor moved event.',0
	string_this_is_a_dialog_test db 'This is a dialog test.',0

	string_test db 'test\test1\test2\test3',0
	string_test2 db 'test2',0
	string_test3 db 'test3',0
	string_test4 db 'test4',0

	string_clock db 'clock.bin',0
	string_clock2 db 'clock2.bin',0
	string_space db '   ',0                  ;空格字符串
	string_lf_cr db '\n',0                 ;换行字符串
	time_string_buffer times 32 db 0       ;时间字符串缓存位置
	date_string_buffer times 32 db 0

	page_start dd 0x0000_0000             ;第一个必须为 0
	widget_start 	dd default_edit_text_box ;目前用户页面仅支持文本框				
				 	dd default_open_button
				 	dd default_save_button
				 	dd default_file_name_edit_text_box
					;dd default_edit_text_box_show_dialog
				 	;dd default_edit_text_box_create_file
		dd 0x0000_0000 
		dd 0x0000_0000
		page_end dd 0x0000_0000           ;用户页面结束

	default_edit_text_box:
		.draw_location_y                    dw 0x0010
		.draw_location_x                    dw 0x0000
		.height                             dw 464          ;宽度，也就是上下
	    .width                              dw 640          ;长度，也就是左右
	    .back_ground_color                  dd 0x00ff_ffff  ;控件背景颜色
	    .boarder_width                      dw 0x0000       ;边框大小，以像素为单位(未实现)
	    .boarder_color                      dd 0x0000_0000  ;边框颜色(未实现)
	    .alpha                              dw 0x0000       ;透明度(未实现)
	    .visibility                         dw 0xffff       ;是否可见，为0则不可见

	    ;交互属性
	    .on_mouse_left_button_down_handler  dd 0x0000_0000;on_mouse_left_button_down_handler   ;需要跳转执行的地址，注意只能跳转到当前的应用中
	    .on_mouse_left_button_up_handler    dd 0x0000_0000;on_mouse_left_button_up_handler   ;鼠标左键双击事件执行跳转
	    .on_mouse_right_button_down_handler dd 0x0000_0000;on_mouse_right_button_down_handler   ;鼠标右键按下事件
	    .on_mouse_right_button_up_handler   dd 0x0000_0000;on_mouse_right_button_up_handler   ;鼠标右键释放事件
	    .on_mouse_wheel_roll_down_handler   dd 0x0000_0000;on_mouse_wheel_roll_down_handler   ;鼠标滚轮向上滚动(未实现)
	    .on_mouse_wheel_roll_up_handler     dd 0x0000_0000;on_mouse_wheel_roll_up_handler   ;鼠标滚轮向下滚动(未实现)
	    .on_mouse_wheel_button_down_handler dd 0x0000_0000;on_mouse_wheel_button_down_handler   ;鼠标中键按下(未实现)
	    .on_mouse_wheel_button_up_handler   dd 0x0000_0000;on_mouse_wheel_button_up_handler   ;鼠标中键释放(未实现)
	    .on_mouse_cursor_moved_on_handler   dd 0x0000_0000;on_mouse_cursor_moved_on_handler   ;鼠标在上面
	    .on_mouse_cursor_moved_off_handler  dd on_mouse_cursor_moved_off_handler_default_edit_text_box   ;鼠标移走事件
	    .on_mouse_cursor_moved_handler      dd on_mouse_cursor_moved_handler_default_edit_text_box;0x0000_0000;on_mouse_cursor_moved_handler   ;鼠标在控件上的移动事件(未实现)
	    .on_keyboard_key_down_handler       dd 0x0000_0000;on_keyboard_key_down_handler   ;键盘输入事件
	    .on_keyboard_key_up_handler         dd 0x0000_0000;on_keyboard_key_up_handler   ;键盘释放事件
	    .widget_state_flag                  dw 0x0002        ;控件当前的状态等，0x06表示不可输入，不可滚动

	    ;控件基本属性
	    .widget_id                          dd 0x0000_0000   ;控件ID 用来第一次绘制的时候写入控件ID
	    .widget_type                        dw 0x0003        ;控件类型为文本框
	    .data_input_source                  dd .default_edit_text_box_string  ;数据源的输入
	    .data_output_target                 dd 0x0000_0000   ;数据的输出位置

	    ;控件文本属性
	    .start_draw_location_x              dw 0x0000        ;(未实现)文本的起始绘制位置。
	    .start_draw_location_y              dw 0x0000        ;(未实现)文本的起始绘制位置，Y轴。
	    .current_text_cursor_loc_y          dw 0x0000        ;(未实现)当前光标的位置y轴。
	    .current_cursor_offset_in_text      dd 0x0000_0000   ;(未实现)当前光标在文本中的位置。
	    .last_start_show_offset_in_text     dd 0x0000_0000   ;上一个起始显示的字符串位置。
	                                                         ;(未实现)当文本超过了一个页面的时候，自动给它新申请一段内存地址用于存放连续的内容
	    .text_length                        dd 0x0000_0000   ;(未实现)字符串长度超过4096个字节的时候自动申请另外一段连续的内存空间给它

	.default_edit_text_box_string: ;Edit Text Box 数据源字符串的结构。
		.string_print_loc_scale dd 0x0000_0000 ;未使用。
		.string_text_size dd 0x0008_0010 ;字体大小，单位为像素，目前仅支持的大小，请勿修改。
		.string_text_color dd 0x00050505 ;字体的颜色。8bit RGB 。
		.string_text_print_start dd 0x0000_0000 ;字符串的起始显示位置。
		.string_edit_cursor dd 0x0000_0000 ;字符串的编辑指针位置。
		.string_start_address dd .string_buffer ;数据源.
		.string_current_letters dd 0x0000_0000 ;字符串当前的长度.
		.string_buffer_length dd 0x0000_2000   
		.string_buffer times 8192 db 0             ;8192个字节的缓冲区


	default_open_button:
		.draw_location_y                    dw 0x0000
		.draw_location_x                    dw 0x0000
		.height                             dw 16          ;宽度，也就是上下
	    .width                              dw 72          ;长度，也就是左右
	    .back_ground_color                  dd COLOR_TITLE_BAR_UNFOCUS  ;控件背景颜色
	    .boarder_width                      dw 0x0000       ;边框大小，以像素为单位(未实现)
	    .boarder_color                      dd 0x0000_0000  ;边框颜色(未实现)
	    .alpha                              dw 0x0000       ;透明度(未实现)
	    .visibility                         dw 0xffff       ;是否可见，为0则不可见

	    ;交互属性
	    .on_mouse_left_button_down_handler  dd on_mouse_left_button_down_handler_open   ;需要跳转执行的地址，注意只能跳转到当前的应用中
	    .on_mouse_left_button_up_handler    dd 0x0000_0000;on_mouse_left_button_up_handler   ;鼠标左键双击事件执行跳转
	    .on_mouse_right_button_down_handler dd 0x0000_0000;on_mouse_right_button_down_handler   ;鼠标右键按下事件
	    .on_mouse_right_button_up_handler   dd 0x0000_0000;on_mouse_right_button_up_handler   ;鼠标右键释放事件
	    .on_mouse_wheel_roll_down_handler   dd 0x0000_0000;on_mouse_wheel_roll_down_handler   ;鼠标滚轮向上滚动(未实现)
	    .on_mouse_wheel_roll_up_handler     dd 0x0000_0000;on_mouse_wheel_roll_up_handler   ;鼠标滚轮向下滚动(未实现)
	    .on_mouse_wheel_button_down_handler dd 0x0000_0000;on_mouse_wheel_button_down_handler   ;鼠标中键按下(未实现)
	    .on_mouse_wheel_button_up_handler   dd 0x0000_0000;on_mouse_wheel_button_up_handler   ;鼠标中键释放(未实现)
	    .on_mouse_cursor_moved_on_handler   dd 0x0000_0000;on_mouse_cursor_moved_on_handler   ;鼠标在上面
	    .on_mouse_cursor_moved_off_handler  dd 0x0000_0000;on_mouse_cursor_moved_off_handler   ;鼠标移走事件
	    .on_mouse_cursor_moved_handler      dd 0x0000_0000;on_mouse_cursor_moved_handler   ;鼠标在控件上的移动事件(未实现)
	    .on_keyboard_key_down_handler       dd 0x0000_0000;on_keyboard_key_down_handler   ;键盘输入事件
	    .on_keyboard_key_up_handler         dd 0x0000_0000;on_keyboard_key_up_handler   ;键盘释放事件
	    .widget_state_flag                  dw 0x0006        ;控件当前的状态等，0x06表示不可输入，不可滚动

	    ;控件基本属性
	    .widget_id                          dd 0x0000_0000   ;控件ID 用来第一次绘制的时候写入控件ID
	    .widget_type                        dw 0x0003        ;控件类型为文本框
	    .data_input_source                  dd .default_edit_text_box_string  ;数据源的输入
	    .data_output_target                 dd 0x0000_0000   ;数据的输出位置

	    ;控件文本属性
	    .start_draw_location_x              dw 0x0000        ;(未实现)文本的起始绘制位置。
	    .start_draw_location_y              dw 0x0000        ;(未实现)文本的起始绘制位置，Y轴。
	    .current_text_cursor_loc_y          dw 0x0000        ;(未实现)当前光标的位置y轴。
	    .current_cursor_offset_in_text      dd 0x0000_0000   ;(未实现)当前光标在文本中的位置。
	    .last_start_show_offset_in_text     dd 0x0000_0000   ;上一个起始显示的字符串位置。
	                                                         ;(未实现)当文本超过了一个页面的时候，自动给它新申请一段内存地址用于存放连续的内容
	    .text_length                        dd 0x0000_0000   ;(未实现)字符串长度超过4096个字节的时候自动申请另外一段连续的内存空间给它
	    ;文本框控件的字符串结构体
		.default_edit_text_box_string: ;Edit Text Box 数据源字符串的结构。
			.string_print_loc_scale dd 0x0000_0000 ;未使用。
			.string_text_size dd 0x0008_0010 ;字体大小，单位为像素，目前仅支持的大小，请勿修改。
			.string_text_color dd 0x00050505 ;字体的颜色。8bit RGB 。
			.string_text_print_start dd 0x0000_0000 ;字符串的起始显示位置。
			.string_edit_cursor dd 0x0000_0000 ;字符串的编辑指针位置。
			.string_start_address dd .string_buffer ;数据源.
			.string_current_letters dd 0x0000_0000 ;字符串当前的长度.
			.string_buffer_length dd 0x0000_0020   
			.string_buffer db 'open file',0
			times 32-($-.string_buffer) db 0

	default_save_button:
		.draw_location_y                    dw 0x0000
		.draw_location_x                    dw 0x0050
		.height                             dw 16          ;宽度，也就是上下
	    .width                              dw 72          ;长度，也就是左右
	    .back_ground_color                  dd COLOR_TITLE_BAR_UNFOCUS  ;控件背景颜色
	    .boarder_width                      dw 0x0000       ;边框大小，以像素为单位(未实现)
	    .boarder_color                      dd 0x0000_0000  ;边框颜色(未实现)
	    .alpha                              dw 0x0000       ;透明度(未实现)
	    .visibility                         dw 0xffff       ;是否可见，为0则不可见

	    ;交互属性
	    .on_mouse_left_button_down_handler  dd on_mouse_left_button_down_handler_save   ;需要跳转执行的地址，注意只能跳转到当前的应用中
	    .on_mouse_left_button_up_handler    dd 0x0000_0000;on_mouse_left_button_up_handler   ;鼠标左键双击事件执行跳转
	    .on_mouse_right_button_down_handler dd 0x0000_0000;on_mouse_right_button_down_handler   ;鼠标右键按下事件
	    .on_mouse_right_button_up_handler   dd 0x0000_0000;on_mouse_right_button_up_handler   ;鼠标右键释放事件
	    .on_mouse_wheel_roll_down_handler   dd 0x0000_0000;on_mouse_wheel_roll_down_handler   ;鼠标滚轮向上滚动(未实现)
	    .on_mouse_wheel_roll_up_handler     dd 0x0000_0000;on_mouse_wheel_roll_up_handler   ;鼠标滚轮向下滚动(未实现)
	    .on_mouse_wheel_button_down_handler dd 0x0000_0000;on_mouse_wheel_button_down_handler   ;鼠标中键按下(未实现)
	    .on_mouse_wheel_button_up_handler   dd 0x0000_0000;on_mouse_wheel_button_up_handler   ;鼠标中键释放(未实现)
	    .on_mouse_cursor_moved_on_handler   dd 0x0000_0000;on_mouse_cursor_moved_on_handler   ;鼠标在上面
	    .on_mouse_cursor_moved_off_handler  dd 0x0000_0000;on_mouse_cursor_moved_off_handler   ;鼠标移走事件
	    .on_mouse_cursor_moved_handler      dd 0x0000_0000;on_mouse_cursor_moved_handler   ;鼠标在控件上的移动事件(未实现)
	    .on_keyboard_key_down_handler       dd 0x0000_0000;on_keyboard_key_down_handler   ;键盘输入事件
	    .on_keyboard_key_up_handler         dd 0x0000_0000;on_keyboard_key_up_handler   ;键盘释放事件
	    .widget_state_flag                  dw 0x0006        ;控件当前的状态等，0x06表示不可输入，不可滚动

	    ;控件基本属性
	    .widget_id                          dd 0x0000_0000   ;控件ID 用来第一次绘制的时候写入控件ID
	    .widget_type                        dw 0x0003        ;控件类型为文本框
	    .data_input_source                  dd .default_edit_text_box_string  ;数据源的输入
	    .data_output_target                 dd 0x0000_0000   ;数据的输出位置

	    ;控件文本属性
	    .start_draw_location_x              dw 0x0000        ;(未实现)文本的起始绘制位置。
	    .start_draw_location_y              dw 0x0000        ;(未实现)文本的起始绘制位置，Y轴。
	    .current_text_cursor_loc_y          dw 0x0000        ;(未实现)当前光标的位置y轴。
	    .current_cursor_offset_in_text      dd 0x0000_0000   ;(未实现)当前光标在文本中的位置。
	    .last_start_show_offset_in_text     dd 0x0000_0000   ;上一个起始显示的字符串位置。
	                                                         ;(未实现)当文本超过了一个页面的时候，自动给它新申请一段内存地址用于存放连续的内容
	    .text_length                        dd 0x0000_0000   ;(未实现)字符串长度超过4096个字节的时候自动申请另外一段连续的内存空间给它
	    ;文本框控件的字符串结构体
		.default_edit_text_box_string: ;Edit Text Box 数据源字符串的结构。
			.string_print_loc_scale dd 0x0000_0000 ;未使用。
			.string_text_size dd 0x0008_0010 ;字体大小，单位为像素，目前仅支持的大小，请勿修改。
			.string_text_color dd 0x00050505 ;字体的颜色。8bit RGB 。
			.string_text_print_start dd 0x0000_0000 ;字符串的起始显示位置。
			.string_edit_cursor dd 0x0000_0000 ;字符串的编辑指针位置。
			.string_start_address dd .string_buffer ;数据源.
			.string_current_letters dd 0x0000_0000 ;字符串当前的长度.
			.string_buffer_length dd 0x0000_0020   
			.string_buffer db 'save file',0
			times 32-($-.string_buffer) db 0

	default_file_name_edit_text_box:
		.draw_location_y                    dw 0x0000
		.draw_location_x                    dw 0x00a0
		.height                             dw 16          ;宽度，也就是上下
	    .width                              dw 0x01e0          ;长度，也就是左右
	    .back_ground_color                  dd COLOR_TITLE_BAR_UNFOCUS  ;控件背景颜色
	    .boarder_width                      dw 0x0000       ;边框大小，以像素为单位(未实现)
	    .boarder_color                      dd 0x0000_0000  ;边框颜色(未实现)
	    .alpha                              dw 0x0000       ;透明度(未实现)
	    .visibility                         dw 0xffff       ;是否可见，为0则不可见

	    ;交互属性
	    .on_mouse_left_button_down_handler  dd 0x0000_0000   ;需要跳转执行的地址，注意只能跳转到当前的应用中
	    .on_mouse_left_button_up_handler    dd 0x0000_0000;on_mouse_left_button_up_handler   ;鼠标左键双击事件执行跳转
	    .on_mouse_right_button_down_handler dd 0x0000_0000;on_mouse_right_button_down_handler   ;鼠标右键按下事件
	    .on_mouse_right_button_up_handler   dd 0x0000_0000;on_mouse_right_button_up_handler   ;鼠标右键释放事件
	    .on_mouse_wheel_roll_down_handler   dd 0x0000_0000;on_mouse_wheel_roll_down_handler   ;鼠标滚轮向上滚动(未实现)
	    .on_mouse_wheel_roll_up_handler     dd 0x0000_0000;on_mouse_wheel_roll_up_handler   ;鼠标滚轮向下滚动(未实现)
	    .on_mouse_wheel_button_down_handler dd 0x0000_0000;on_mouse_wheel_button_down_handler   ;鼠标中键按下(未实现)
	    .on_mouse_wheel_button_up_handler   dd 0x0000_0000;on_mouse_wheel_button_up_handler   ;鼠标中键释放(未实现)
	    .on_mouse_cursor_moved_on_handler   dd 0x0000_0000;on_mouse_cursor_moved_on_handler   ;鼠标在上面
	    .on_mouse_cursor_moved_off_handler  dd 0x0000_0000;on_mouse_cursor_moved_off_handler   ;鼠标移走事件
	    .on_mouse_cursor_moved_handler      dd 0x0000_0000;on_mouse_cursor_moved_handler   ;鼠标在控件上的移动事件(未实现)
	    .on_keyboard_key_down_handler       dd 0x0000_0000;on_keyboard_key_down_handler   ;键盘输入事件
	    .on_keyboard_key_up_handler         dd 0x0000_0000;on_keyboard_key_up_handler   ;键盘释放事件
	    .widget_state_flag                  dw 0x0002        ;控件当前的状态等，0x06表示不可输入，不可滚动

	    ;控件基本属性
	    .widget_id                          dd 0x0000_0000   ;控件ID 用来第一次绘制的时候写入控件ID
	    .widget_type                        dw 0x0003        ;控件类型为文本框
	    .data_input_source                  dd .default_edit_text_box_string  ;数据源的输入
	    .data_output_target                 dd 0x0000_0000   ;数据的输出位置

	    ;控件文本属性
	    .start_draw_location_x              dw 0x0000        ;(未实现)文本的起始绘制位置。
	    .start_draw_location_y              dw 0x0000        ;(未实现)文本的起始绘制位置，Y轴。
	    .current_text_cursor_loc_y          dw 0x0000        ;(未实现)当前光标的位置y轴。
	    .current_cursor_offset_in_text      dd 0x0000_0000   ;(未实现)当前光标在文本中的位置。
	    .last_start_show_offset_in_text     dd 0x0000_0000   ;上一个起始显示的字符串位置。
	                                                         ;(未实现)当文本超过了一个页面的时候，自动给它新申请一段内存地址用于存放连续的内容
	    .text_length                        dd 0x0000_0000   ;(未实现)字符串长度超过4096个字节的时候自动申请另外一段连续的内存空间给它
	    ;文本框控件的字符串结构体
		.default_edit_text_box_string: ;Edit Text Box 数据源字符串的结构。
			.string_print_loc_scale dd 0x0000_0000 ;未使用。
			.string_text_size dd 0x0008_0010 ;字体大小，单位为像素，目前仅支持的大小，请勿修改。
			.string_text_color dd 0x00050505 ;字体的颜色。8bit RGB 。
			.string_text_print_start dd 0x0000_0000 ;字符串的起始显示位置。
			.string_edit_cursor dd 0x0000_0000 ;字符串的编辑指针位置。
			.string_start_address dd .string_buffer ;数据源.
			.string_current_letters dd 0x0000_0000 ;字符串当前的长度.
			.string_buffer_length dd 0x0000_00ff   
			.string_buffer db 'newtext.txt',0
			times 255-($-.string_buffer) db 0





	default_edit_text_box_show_dialog:
		.draw_location_y                    dw 95
		.draw_location_x                    dw 95
		.height                             dw 20          ;宽度，也就是上下
	    .width                              dw 95          ;长度，也就是左右
	    .back_ground_color                  dd COLOR_TITLE_BAR  ;控件背景颜色
	    .boarder_width                      dw 0x0000       ;边框大小，以像素为单位(未实现)
	    .boarder_color                      dd 0x0000_0000  ;边框颜色(未实现)
	    .alpha                              dw 0x0000       ;透明度(未实现)
	    .visibility                         dw 0xffff       ;是否可见，为0则不可见

	    ;交互属性
	    .on_mouse_left_button_down_handler  dd show_dialog   ;需要跳转执行的地址，注意只能跳转到当前的应用中
	    .on_mouse_left_button_up_handler    dd 0   ;鼠标左键双击事件执行跳转
	    .on_mouse_right_button_down_handler dd 0   ;鼠标右键按下事件
	    .on_mouse_right_button_up_handler   dd 0   ;鼠标右键释放事件
	    .on_mouse_wheel_roll_down_handler   dd 0   ;鼠标滚轮向上滚动
	    .on_mouse_wheel_roll_up_handler     dd 0   ;鼠标滚轮向下滚动
	    .on_mouse_wheel_button_down_handler dd 0   ;鼠标中键按下
	    .on_mouse_wheel_button_up_handler   dd 0   ;鼠标中键释放
	    .on_mouse_cursor_moved_on_handler   dd 0   ;鼠标在上面
	    .on_mouse_cursor_moved_off_handler  dd 0   ;鼠标移走事件
	    .on_mouse_cursor_moved_handler      dd 0   ;鼠标在控件上的移动事件
	    .on_keyboard_key_down_handler       dd 0   ;键盘输入事件
	    .on_keyboard_key_up_handler         dd 0  ;键盘释放事件
	    .widget_state_flag                  dw 0x0006        ;控件当前的状态等，0x06表示不可输入，不可滚动

	    ;控件基本属性
	    .widget_id                          dd 0x0000_0000   ;控件ID 用来第一次绘制的时候写入控件ID
	    .widget_type                        dw 0x0003        ;控件类型为文本框
	    .data_input_source                  dd .default_string  ;数据源的输入
	    .data_output_target                 dd 0x0000_0000   ;数据的输出位置

	    ;控件文本属性
	    .start_draw_location_x              dw 0x0000        ;(未实现)文本的起始绘制位置。
	    .start_draw_location_y              dw 0x0000        ;(未实现)文本的起始绘制位置，Y轴。
	    .current_text_cursor_loc_y          dw 0x0000        ;(未实现)当前光标的位置y轴。
	    .current_cursor_offset_in_text      dd 0x0000_0000   ;(未实现)当前光标在文本中的位置。
	    .last_start_show_offset_in_text     dd 0x0000_0000   ;上一个起始显示的字符串位置。
	                                                         ;(未实现)当文本超过了一个页面的时候，自动给它新申请一段内存地址用于存放连续的内容
	    .text_length                        dd 0x0000_0000   ;(未实现)字符串长度超过4096个字节的时候自动申请另外一段连续的内存空间给它

		.default_string: ;Edit Text Box 数据源字符串的结构。
			.string_print_loc_scale dd 0x0000_0000 ;未使用。
			.string_text_size dd 0x0008_0010 ;字体大小，单位为像素，目前仅支持的大小，请勿修改。
			.string_text_color dd 0x00050505 ;字体的颜色。8bit RGB 。
			.string_text_print_start dd 0x0000_0000 ;字符串的起始显示位置。
			.string_edit_cursor dd 0x0000_0000 ;字符串的编辑指针位置。
			.string_start_address dd .string_buffer ;数据源.
			.string_current_letters dd 0x0000_0000 ;字符串当前的长度.
			.string_buffer_length dd 0x0000_0020   
			.string_buffer db 'show dialog',0
			times 32-($-.string_buffer) db 0

	default_edit_text_box_create_file:
		.draw_location_y                    dw 95
		.draw_location_x                    dw 200
		.height                             dw 20          ;宽度，也就是上下
	    .width                              dw 95          ;长度，也就是左右
	    .back_ground_color                  dd COLOR_TITLE_BAR  ;控件背景颜色
	    .boarder_width                      dw 0x0000       ;边框大小，以像素为单位(未实现)
	    .boarder_color                      dd 0x0000_0000  ;边框颜色(未实现)
	    .alpha                              dw 0x0000       ;透明度(未实现)
	    .visibility                         dw 0xffff       ;是否可见，为0则不可见

	    ;交互属性
	    .on_mouse_left_button_down_handler  dd create_file   ;需要跳转执行的地址，注意只能跳转到当前的应用中
	    .on_mouse_left_button_up_handler    dd 0   ;鼠标左键双击事件执行跳转
	    .on_mouse_right_button_down_handler dd 0   ;鼠标右键按下事件
	    .on_mouse_right_button_up_handler   dd 0   ;鼠标右键释放事件
	    .on_mouse_wheel_roll_down_handler   dd 0   ;鼠标滚轮向上滚动
	    .on_mouse_wheel_roll_up_handler     dd 0   ;鼠标滚轮向下滚动
	    .on_mouse_wheel_button_down_handler dd 0   ;鼠标中键按下
	    .on_mouse_wheel_button_up_handler   dd 0   ;鼠标中键释放
	    .on_mouse_cursor_moved_on_handler   dd 0   ;鼠标在上面
	    .on_mouse_cursor_moved_off_handler  dd 0   ;鼠标移走事件
	    .on_mouse_cursor_moved_handler      dd 0   ;鼠标在控件上的移动事件
	    .on_keyboard_key_down_handler       dd 0   ;键盘输入事件
	    .on_keyboard_key_up_handler         dd 0   ;键盘释放事件
	    .widget_state_flag                  dw 0x0006        ;控件当前的状态等，0x06表示不可输入，不可滚动

	    ;控件基本属性
	    .widget_id                          dd 0x0000_0000   ;控件ID 用来第一次绘制的时候写入控件ID
	    .widget_type                        dw 0x0003        ;控件类型为文本框
	    .data_input_source                  dd .default_string  ;数据源的输入
	    .data_output_target                 dd 0x0000_0000   ;数据的输出位置

	    ;控件文本属性
	    .start_draw_location_x              dw 0x0000        ;(未实现)文本的起始绘制位置。
	    .start_draw_location_y              dw 0x0000        ;(未实现)文本的起始绘制位置，Y轴。
	    .current_text_cursor_loc_y          dw 0x0000        ;(未实现)当前光标的位置y轴。
	    .current_cursor_offset_in_text      dd 0x0000_0000   ;(未实现)当前光标在文本中的位置。
	    .last_start_show_offset_in_text     dd 0x0000_0000   ;上一个起始显示的字符串位置。
	                                                         ;(未实现)当文本超过了一个页面的时候，自动给它新申请一段内存地址用于存放连续的内容
	    .text_length                        dd 0x0000_0000   ;(未实现)字符串长度超过4096个字节的时候自动申请另外一段连续的内存空间给它

		.default_string: ;Edit Text Box 数据源字符串的结构。
			.string_print_loc_scale dd 0x0000_0000 ;未使用。
			.string_text_size dd 0x0008_0010 ;字体大小，单位为像素，目前仅支持的大小，请勿修改。
			.string_text_color dd 0x00050505 ;字体的颜色。8bit RGB 。
			.string_text_print_start dd 0x0000_0000 ;字符串的起始显示位置。
			.string_edit_cursor dd 0x0000_0000 ;字符串的编辑指针位置。
			.string_start_address dd .string_buffer ;数据源.
			.string_current_letters dd 0x0000_0000 ;字符串当前的长度.
			.string_buffer_length dd 0x0000_0020   
			.string_buffer db 'create file',0
			times 32-($-.string_buffer) db 0

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
	    .on_mouse_left_button_down_handler  dd on_mouse_left_button_down_handler   ;需要跳转执行的地址，注意只能跳转到当前的应用中
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