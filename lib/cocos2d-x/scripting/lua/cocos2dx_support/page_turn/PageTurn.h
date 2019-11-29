
#ifndef __PageTurn_H__
#define __PageTurn_H__

#include "cocos2d.h"
#include "CCLuaValue.h"

using namespace cocos2d;
using namespace std;

class PageTurn : public CCNode
{
public:
	PageTurn();
	~PageTurn();
	static PageTurn* create(string strBg,string strFr);
    virtual bool init(string strBg,string strFr);
    virtual void setRotation(float fRotation);
    virtual float getRotation();
    virtual void setPosition(const CCPoint &position);
    virtual void setPosition(float x, float y);
    virtual bool ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent);
    virtual void ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent);
    virtual void setScale(float fScale);//放大缩小
    virtual void setScaleX(float newScaleX);
    virtual void setScaleY(float newScaleY);
    virtual void setRotationX(float fRotationX);
    virtual void setRotationY(float fRotationX);
    virtual void onExit();


    void turnFromLeftBottom(float offset);//从左下角开始翻
    void turnFromLeft(float offset);//从左开始翻
	void turnFromRightBottom(float offset);//从右下角开始牌
    void turnFromRight(float offset);//从右开始翻
	void turnFromMid(float offset);//从中间翻牌

    //设置偏移 和 偏移缩放比
    void setTurnOffset(int turnType ,float rate, int offset);
    //设置松开后 回缩速度
    void setBackValue(int backValue);

    void turnFront();//前转90度
    void turnBack();//回转90
    float getTurnValue();//取翻转值
    int  getTurnType();//翻转方式,1=左，2=右，3=中间
    void showCard();//直接翻牌
    void setStop(bool bStop);//停止后不能翻牌
    bool getStop();
    void turnCard(int iType,float offset);//传值后翻牌
    bool getShowCard();//是否已翻牌
    void setStopCallbackHandler(LUA_FUNCTION handler);//翻到最大角度后调用lua回调
    void setChangeCallbackHandler(LUA_FUNCTION handler);//在翻牌时差值改变

    void setTouchEndCallbackHandler(LUA_FUNCTION handler);//触摸结束回调函数

    void setGridActivie(bool bActive);//是否使用grid渲染
    void setTouchEnable(bool enable);
private:
	CCGridBase* _getGrid(CCSprite* spr);//给指定节点创建3d网格
	ccVertex3F _getOriginalVertex(const CCPoint& position,CCNode* node = nullptr);//取指定node的顶点数据
	void _setVertex(const CCPoint& position, const ccVertex3F& vertex,CCNode* node = nullptr);
    ccVertex3F _getVertex(const CCPoint& position,CCNode* node = nullptr);
    void _stopCallbackLua();
    void _changeCallbackLua();
    void _autoTurn(float dt);//定时器中翻转牌
    void _touchEndCallbackLua();
    
    int _clickType; //按键状态

	CCNode* _cardBg;//牌背
	CCNode* _cardFr;//牌面
	CCSize _gridSize;//风格大小
    float _fHorizontalAngle;//水平的角度大于这个角度就显示牌面
    int _iBigZorder;//两张牌的zorder值
    int _iMinZorder;
    CCPoint _touchBegin;
    CCPoint _touchMove;
    CCPoint _touchEnd;
    float _fRotation;//旋转角度
    float _fTurnValue;//翻转了的差值

    float _fFinalValue;//翻停后的值
    float _bStop;//true 停止翻牌
    float _fStopAngle;//中间点到到这个角度后停止翻牌直接显示
    int _iTurnType;//翻牌方式
    LUA_FUNCTION _stopCallbackHandler;//停止翻牌后调用lua
    LUA_FUNCTION _changeCallbackHandler;//翻牌中回调用lua
    bool _bShowCard;//是否已翻牌
    float callIntervalCount ;
    float callInterval ;
    float _dValue;//翻牌定时器里的差值
    SEL_SCHEDULE _selectorTurn;//开个定时器防止翻牌过快
    bool _bEnable;


    //csj 偏移量 和 偏移缩放度
    float __midRate;  float __leftRate;  float __rightRate;  float __rightBottomRate;  float __leftBottomRate;
    int __midOffset;  int __leftOffset;  int __rightOffset;  int __rightBottomOffset;  int __leftBottomOffset;

    //csj 回缩速度
    int __backValue;

    //csj 触摸结束回调函数
    LUA_FUNCTION __touchEndCallbackHander; //触摸结束回调函数
};

#endif // __ACTION_CCPAGETURN3D_ACTION_H__
