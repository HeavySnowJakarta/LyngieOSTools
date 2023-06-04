/* By QQ User 来自山东的大蒜王师傅

DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
Version 2, December 2004 
Copyright (C) 2004 Sam Hoicevar <sam@hocevar.net> 
Everyone is permitted to copy and distribute verbatim or modified copies of this license document, and changing it is allowed as long as the name is changed.
DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 
  0. You just DO WHAT THE FUCK YOU WANT TO.
*/

#include "lynwindow.h"
#include "lynstd.h"
#include "lyndef.h"
#include "lynlib.h"
#define MAX 100
// 各种颜色定义===================================================
static uint32_t editBackColor = 0x00a0a0a0;
static uint32_t btnBackColor = 0x00a0e0a0;
static uint32_t btnBackcolorDown = 0x00508050;
// 窗口组件定义===================================================
static WindowClass* window;         // 窗口
static WindowDescription* rootPanel;   // 根容器
static WindowClass* editBox;            // 编辑框
static WindowClass* btnArray[20];       // 按钮数组
static WindowClass* btn;
static char btnText[20][3] =              // 按钮文本
{
    "7", "8", "9", "+", "(",
    "4", "5", "6", "-", ")",
    "1", "2", "3", "*", "<-",
    "0", ".", "=", "/", "C",
};
// 计算逻辑*******************************************************

// 函数声明
float calculate(char *expression);

// 函数定义
float eval_expression(char **expr);
float eval_term(char **expr);
float eval_factor(char **expr);
// 包含运算符
bool containControlOp(char* s);


// 初始化窗口
void initWindow();
// 按钮按下回调
void onBtnDown();
// 按钮松开回调
void onBtnUp();
// 开始计算
void startCalc();
// 主函数
void lynmain(){
    initWindow();
}

void initWindow()
{
    // 先获取系统级组件化根窗口
    unsigned int control, tempwindow, ascii;
	GET_MSG_INFO(control, tempwindow, ascii);
    window = (WindowClass*)tempwindow;
    // 设置窗口大小
    window->width = 260;
    window->height = 268;
    // 创建窗口容器
    rootPanel = InitWindowInfo();//初始化窗口框架
    // 创建编辑框
    editBox = CreateEditBox(10,10,240,30,editBackColor,0);
    AddChildWindowToFrameWindow(rootPanel, editBox);

    // 批量创建按钮
    for(int i=0;i<20;i++)
    {
        btnArray[i] = CreateButton(10+(i%5)*50,50+(i/5)*50,40,40,btnBackColor, onBtnUp);
        SetWindowText(rootPanel, btnArray[i], btnText[i]);
        SetCallback(&(btnArray[i]->on_mouse_left_button_down_handler), onBtnDown);
        AddChildWindowToFrameWindow(rootPanel, btnArray[i]); 

    }
    // AddChildWindowToFrameWindow(rootPanel, CreateEditBox(50, 50, 40, 40, btnBackColor, 0));
    // 显示窗口
    
    CreateFrameWindow(rootPanel);
}

void onBtnDown()
{
    unsigned int control, window, ascii;
	GET_MSG_INFO(control, window, ascii);
    WindowClass* btn = (WindowClass*)control;
    // 设置按钮按下颜色
    btn->back_ground_color = btnBackcolorDown;
}

void onBtnUp()
{
    unsigned int control, window, ascii;
	GET_MSG_INFO(control, window, ascii);
    WindowClass* btn = (WindowClass*)control;
    // 恢复按钮颜色
    btn->back_ground_color = btnBackColor;
    char cmdStr[8];
    GetWindowText(rootPanel, btn,cmdStr, 4);
    char c = cmdStr[0];
    if(c>='0' && c<='9' || c=='*' || c=='/' 
        || c=='+' || c=='-' || c=='(' 
        || c==')' || c=='.')
    {
        char s[2];
        s[0] = c; s[1]='\0';
        AppendWindowText(rootPanel, editBox, s);
    }
    else if(c == 'C'){
        char s[2]="";
        SetWindowText(rootPanel, editBox, " ");
        SetWindowText(rootPanel, editBox, "");
    }
    else if(c=='<'){
        char oldStr[128];
        GetWindowText(rootPanel, editBox, oldStr, 128);
        int l = Strlen(oldStr);
        if(l>1){
            oldStr[l-1]='\0';
            SetWindowText(rootPanel, editBox, oldStr);
        }
        else if(l==1){
            SetWindowText(rootPanel, editBox, " ");
            SetWindowText(rootPanel, editBox, "");
        }
       
        
    }
    else if(c=='='){
        // AppendWindowText(rootPanel, editBox, "=");
        startCalc();
    }
}

void startCalc()
{
    
    
    // 读取表达式
    char exep[128];
    GetWindowText(rootPanel, editBox, exep, 128);
    
    if(containControlOp(exep)){
        float result = calculate(exep);
      
        char reStr[32];
        Sprintf(reStr, " %.5f", result+0.00005);
        // 删除末尾的0
        int i = Strlen(reStr)-1;
        while(reStr[i]=='0'){
            reStr[i] = '\0';
            i--;
        }
        if(reStr[i]='.'){
            reStr[i] = '\0';
        }
        SetWindowText(rootPanel, editBox, reStr);
    }
	
}

// 计算逻辑
// 计算函数
float calculate(char *expression) {
    char *expr = expression;
    return eval_expression(&expr);
}

// 解析并计算表达式
float eval_expression(char **expr) {
    float result = eval_term(expr);

    while (**expr == '+' || **expr == '-') {
        char op = *(*expr)++;
        float term = eval_term(expr);

        if (op == '+') {
            result += term;
        } else {
            result -= term;
        }
    }

    return result;
}

// 解析并计算项
float eval_term(char **expr) {
    float result = eval_factor(expr);

    while (**expr == '*' || **expr == '/') {
        char op = *(*expr)++;
        float factor = eval_factor(expr);

        if (op == '*') {
            result *= factor;
        } else {
            if (factor == 0) {
                // printf("Error: Division by zero\n");
                
            }
            result /= factor;
        }
    }

    return result;
}

// 解析并计算因子
float eval_factor(char **expr) {
    float result;

    if (**expr == '(') {
        (*expr)++;
        result = eval_expression(expr);

        if (**expr == ')') {
            (*expr)++;
        } else {
            // printf("Error: Unbalanced parentheses\n");
            // exit(EXIT_FAILURE);
        }
    } else {
        result = strtof(*expr, expr);
    }

    return result;
}
bool containControlOp(char *s)
{
    // 判断表达式是否含运算符
    for(char* c = s; *c!='\0'; c++){
        if(*c=='+'||*c=='-'||*c=='*'||*c=='/'){
            return true;
        }
    }
    return false;
}
