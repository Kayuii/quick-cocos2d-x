
#include "PageTurn.h"
#include "MyGrid.h"
#include "CCLuaEngine.h"

PageTurn::PageTurn()
:callIntervalCount(0),
_cardBg(nullptr),
_cardFr(nullptr),
_clickType(-1),
callInterval(0.1),

__rightRate(1),
__rightBottomRate(1),
__midRate(1),
__leftRate(1),
__leftBottomRate(1),

__midOffset(0),
__leftOffset(0),
__rightOffset(0),
__leftBottomOffset(0),
__rightBottomOffset(0),
__backValue(20),
__touchEndCallbackHander(NULL)
{

    
}


PageTurn::~PageTurn(){
	if(_cardBg){
		_cardBg->setGrid(nullptr);
	}
    if(_cardFr){
        _cardFr->setGrid(nullptr);
    }
}

PageTurn* PageTurn::create(string strBg,string strFr)
{
	PageTurn *action = new  PageTurn();

	if (action)
	{
		if (action->init(strBg,strFr))
		{
			action->autorelease();
		}
		else
		{
			CC_SAFE_RELEASE_NULL(action);
		}
	}

	return action;
}

void PageTurn::onExit()
{
    CCDirector::sharedDirector()->getTouchDispatcher()->removeDelegate(this);
}

bool PageTurn::init(string strBg,string strFr)
{

    if(!CCNode::init()){
        return false;
    }
	_gridSize = CCSize(80,80);
    _fHorizontalAngle = 1.8f;//103度
    _iBigZorder = 20;
    _iMinZorder = 10;
    _fRotation = 0;
    _fTurnValue = 0;
    _fFinalValue = 0;
    _bStop = true;
    _fStopAngle = 2.2;//126度
    _iTurnType = 0;//1=左，2=右，3=中
    _bShowCard = false;
    _stopCallbackHandler = 0;
    _changeCallbackHandler = 0;
    _dValue = 0;
    
    
    //根据牌面值创建
    //牌面
    _cardFr = CCSprite::create(strFr.c_str());
    _cardFr->setScaleY(-getScaleY());
    CCGridBase* cradFrGrid = _getGrid((CCSprite*)_cardFr);
    _cardFr->setGrid(cradFrGrid);
    addChild(_cardFr, 0);
    //牌背
    _cardBg = CCSprite::create(strBg.c_str());
    setContentSize(_cardBg->getContentSize());
    addChild(_cardBg, 0);
    auto newgrid = _getGrid((CCSprite*)_cardBg);
    _cardBg->setGrid(newgrid);
    //接收点击事件, m_uReference 会加1, 在onexit中要移除
    CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this, -129, false);

    setStop(true);//不可以翻牌
    setGridActivie(false);
    setTouchEnable(false);
    

    return true;
}

void PageTurn::setGridActivie(bool bActive)
{
    if(!_cardFr || !_cardBg){
        return;
    }
    _cardBg->getGrid()->setActive(bActive);
    _cardFr->getGrid()->setActive(bActive);
    if(!bActive){
        CCPoint pt = ccp(0,0);
        _cardFr->setPosition(pt);
        _cardBg->setPosition(pt);
    }else{
        CCPoint pt = getPosition();
        float fRotation = getRotation();
        setRotation(fRotation);
        float fScale = getScale();
        setScale(fScale);
        setPosition(pt);
    }
}

void PageTurn::setPosition(const cocos2d::CCPoint &position)
{
    CCNode::setPosition(position);
    if(_bStop){
        return;
    }
    _cardFr->setPosition(position);
    _cardBg->setPosition(position);
    CCRect rect = _cardBg->boundingBox();
    MyGrid3D* grid = (MyGrid3D*)_cardBg->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
    grid = (MyGrid3D*)_cardFr->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
    
}

void PageTurn::setPosition(float x, float y)
{
    CCPoint position = ccp(x,y);
    setPosition(position);
}

void PageTurn::setRotation(float fRotation)
{
     CCNode::setRotation(fRotation);
    _fRotation = fRotation;
    if(_bStop == false){
        if(_fRotation == 90){//如果不旋转触摸点就是反了
            CCNode::setRotation(0);
        }
        _cardFr->setRotation(fRotation);
        _cardBg->setRotation(fRotation);
        CCRect rect = _cardBg->boundingBox();
        MyGrid3D* grid = (MyGrid3D*)_cardBg->getGrid();
        grid->setGridRect(rect);
        grid->calculateVertexPoints();
        grid = (MyGrid3D*)_cardFr->getGrid();
        grid->setGridRect(rect);
        grid->calculateVertexPoints();
    }

}

float PageTurn::getRotation()
{
    return _fRotation;
}

void PageTurn::turnFront()
{
    float rotation = 90;
    if(_fRotation == rotation){
        return;
    }
    setRotation(rotation);
    if(_bStop == false){

    }

}

void PageTurn::turnBack()
{
    float rotation = 0;
    if(_fRotation == rotation){
        return;
    }
    setRotation(rotation);

}


void PageTurn::turnFromMid(float offset)
{
	CCSize nodeSize = getContentSize();
    //CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
	float R = nodeSize.height;
    if(getRotation() == 90){
        R = nodeSize.width;
    }

    offset =  offset*2;
    float pz = 0;
    float offsetX = 0;//偏移
    float offsetY = 0;
    bool bStop = false;
    for (int i = 0; i <= _gridSize.width; ++i)
    {
        for (int j = 0; j <= _gridSize.height; ++j)
        {
            // Get original vertex
            ccVertex3F p = _getOriginalVertex(ccp(i ,j),_cardBg);
            float l = p.y - offset;
            float alpha = l / R;
            pz = p.z;
            if (l <= 0) {
                if (alpha > M_PI) {
                    p.x = p.x + 0;
                    p.y = 0 + offset + R * (alpha - M_PI);
                    p.z = 2 * R / _iMinZorder;
                    pz = 2 * R / _iBigZorder;
                }
                else if (alpha <= M_PI)
                {
                    p.x = p.x + 0;
                    p.y = 0 + offset - R *  sinf(alpha);
                    p.z = (R - R * cosf(alpha)) / _iMinZorder+1;
                    pz = (R - R * cosf(alpha)) / _iBigZorder;
                }
            }
            if(alpha < -0.0001 ){
                p.z = ((R - R * cosf(alpha)) / _iBigZorder);
                pz = (R - R * cosf(alpha)) / _iMinZorder;
            }

            _setVertex(ccp(i, j), p,_cardBg);
            p.z = pz;
            _setVertex(ccp(i, j), p,_cardFr);
            if(i == (int)_gridSize.width/3*2 && j== (int)_gridSize.height/3*2){
                //CCLog("min alpha = %f",alpha);
                if(alpha < -0.33){
                    bStop = true;
                }
            }
        }
    }
    if(bStop){
        _stopCallbackLua();
    }
    
}

void PageTurn::turnFromLeft(float offset)
{
    CCSize nodeSize = getContentSize();
    //CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
    float R = nodeSize.height;
    if(getRotation() == 90){
        R = nodeSize.width;
    }

    offset =  offset;
    // CCLog("pageturn2 offset = %d",offset);
    float pz = 0;
    bool bStop = false;
    for (int i = 0; i <= _gridSize.width; ++i)
    {
        for (int j = 0; j <= _gridSize.height; ++j)
        {
            // Get original vertex
            ccVertex3F p = _getOriginalVertex(ccp(i ,j),_cardBg);
            float l = p.x - offset;

            float alpha = l / R;
            pz = p.z;
            if (l <= 0) {       //左边
                if (alpha > M_PI) {
                    p.x = 0;
                    p.y = 0 + offset + R * (alpha - M_PI);
                    p.z = _iMinZorder;
                    pz = _iBigZorder;
                    // CCLog("pageturn1 l = %f, p.x = %f, p.y = %f, p.z = %f, alpha = %f",l,p.x,p.y,p.z,alpha);
                }
                else if (alpha <= M_PI)
                {
                    p.x = offset - R*sinf(alpha);
                    p.y = p.y;
                    p.z = _iMinZorder+1;
                    pz = _iBigZorder;
                    // CCLog("pageturn2 l = %f, p.x = %f, p.y = %f, p.z = %f, alpha = %f",l,p.x,p.y,p.z,alpha);
                }
            }
            if(alpha < -0.0001 ){
                p.z = ((R - R * cosf(alpha)) / _iBigZorder);
                pz = (R - R * cosf(alpha)) / _iMinZorder;
            }
            
            _setVertex(ccp(i, j), p,_cardBg);
            p.z = pz;
            _setVertex(ccp(i, j), p,_cardFr);
            if(i == (int)_gridSize.width/3*2 && j== (int)_gridSize.height/3*2){
                //CCLog("min alpha = %f",alpha);
                if(alpha < -0.33){
                    bStop = true;
                }
            }
        }
    }
    if(bStop){
        _stopCallbackLua();
    }
}

void PageTurn::turnFromLeftBottom(float offset)
{

	float theta = (GLfloat)(-M_PI *0.16);
	 float R = 50;
    CCSize nodeSize = getContentSize();
	float b = (nodeSize.height + offset * 10) * sinf(theta);
    float offsetX = 0;//偏移
    float offsetY = 0;
    bool bStop = false;
    float pz = 0;
	for (int i = 0; i <= _gridSize.width; ++i)
	{
		for (int j = 0; j <= _gridSize.height; ++j)
		{
			// Get original vertex
			ccVertex3F p = _getOriginalVertex(CCPoint(i, j),_cardBg);
			float x = (p.y + b) / tanf(theta);
			float pivotX = x + (p.x - x) * cosf(theta) * cosf(theta);
			float pivotY = pivotX * tanf(theta) - b;
			float l = (p.x - pivotX) / sinf(theta);
			float alpha = l / R;
            pz = p.z;
			if (l >= 0) {
				if (alpha > M_PI) {
					p.x = (GLfloat)(offsetX + pivotX - R * (alpha - M_PI) * sinf(theta));
					p.y = (GLfloat)(offsetX + pivotY + R * (alpha - M_PI) * cosf(theta));
					p.z = (GLfloat)(2 * R / _iMinZorder);
                    pz = (GLfloat)(2 * R / _iBigZorder);
				}
				else if (alpha <= M_PI)
				{
					p.x = (GLfloat)(offsetX + pivotX + R * sinf(alpha) * sinf(theta));
					p.y = (GLfloat)(offsetX + pivotY - R * sinf(alpha) * cosf(theta));
					p.z = (GLfloat)((R - R * cosf(alpha)) / _iMinZorder);
                    pz = (GLfloat)((R - R * cosf(alpha)) / _iBigZorder);
				}
                
                if(alpha > _fHorizontalAngle){
                    p.z = ((R - R * cosf(alpha)) / _iBigZorder);
                    pz = ((R - R * cosf(alpha)) / _iMinZorder);
                }
                //中心点在于指定角度后显示
                if(i == (int)_gridSize.width/3*2 && j== (int)_gridSize.height/3*2){
                    //CCLog("min alpha = %f",alpha);
                    if(fabs(alpha) > _fStopAngle){
                        bStop = true;
                    }
                }
            }
			// Set new coords
			_setVertex(CCPoint(i, j), p,_cardBg);
            p.z = pz;
            _setVertex(CCPoint(i, j), p,_cardFr);
		}
	}

    if(bStop){
        _stopCallbackLua();
    }
}


void PageTurn::turnFromRight(float offset)
{
     CCSize nodeSize = getContentSize();
    //CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
    float R = nodeSize.height;
    if(getRotation() == 90){
        R = nodeSize.width;
    }

    offset =  offset;
    // CCLog("pageturn turnFromRight offset = %f",offset);
    float pz = 0;
    bool bStop = false;

    float yy = R+offset; //y轴对称点

    for (int i = 0; i <= _gridSize.width; ++i)
    {
        for (int j = 0; j <= _gridSize.height; ++j)
        {
            // Get original vertex
            ccVertex3F p = _getOriginalVertex(ccp(i ,j),_cardBg);
            float l = p.x - offset;

            float alpha = l / R;
            pz = p.z;
            if (l >= R) {       //左边

                if (alpha <= M_PI)
                {
                    p.x = yy-(p.x-yy);
                    p.y = p.y;
                    p.z = _iMinZorder+1;
                    pz = _iBigZorder;
                    // CCLog("pageturn2 l = %f, p.x = %f, p.y = %f, p.z = %f, alpha = %f",l,p.x,p.y,p.z,alpha);
                }else{
                    // CCLog("pageturn3 l = %f, p.x = %f, p.y = %f, p.z = %f, alpha = %f",l,p.x,p.y,p.z,alpha);
                }
            }
            if(alpha < -0.0001 ){
                p.z = ((R - R * cosf(alpha)) / _iBigZorder);
                pz = (R - R * cosf(alpha)) / _iMinZorder;
            }
            
            _setVertex(ccp(i, j), p,_cardBg);
            p.z = pz;
            _setVertex(ccp(i, j), p,_cardFr);
            if(i == (int)_gridSize.width/3*2 && j== (int)_gridSize.height/3*2){
                //CCLog("min alpha = %f",alpha);
                if(alpha < -0.33){
                    bStop = true;
                }
            }
        }
    }
    if(bStop){
        _stopCallbackLua();
    }

}

void PageTurn::turnFromRightBottom(float offset)
{
	CCSize nodeSize = getContentSize();
	float theta = (GLfloat)(M_PI *0.16);
	float R = 50;
	float b = (getContentSize().width - offset * 8) * sinf(theta);
	//float b = -offset  * sinf(theta);
    float offsetX = 0;//偏移
    float offsetY = 0;
    bool bStop = false;
    float pz = 0;
	for (int i = 0; i <= _gridSize.width; ++i)
	{
		for (int j = 0; j <= _gridSize.height; ++j)
		{
			// Get original vertex
			ccVertex3F p = _getOriginalVertex(CCPoint(i, j),_cardBg);
			float x = (p.y + b) / tanf(theta);

			float pivotX = x + (p.x - x) * cosf(theta) * cosf(theta);
			float pivotY = pivotX * tanf(theta) - b;

			float l = (p.x - pivotX) / sinf(theta);
			float alpha = l / R;
            pz = p.z;
			if (l >= 0) {
				if (alpha > M_PI) {
					p.x = (GLfloat)(offsetX + pivotX - R * (alpha - M_PI) * sinf(theta));
					p.y = (GLfloat)(offsetY + pivotY + R * (alpha - M_PI) * cosf(theta));
					p.z = (GLfloat)(2 * R / _iMinZorder);
                    pz = (GLfloat)(2 * R / _iBigZorder);
				}
				else if (alpha <= M_PI)
				{
					p.x = (GLfloat)(offsetX +  pivotX + R * sinf(alpha) * sinf(theta));
					p.y = (GLfloat)(offsetY +  pivotY - R * sinf(alpha) * cosf(theta));
					p.z = (GLfloat)((R - R * cosf(alpha)) / _iMinZorder);
                    pz = (GLfloat)((R - R * cosf(alpha)) / _iBigZorder);
				}

                if(alpha > _fHorizontalAngle){
                    p.z = ((R - R * cosf(alpha)) / _iBigZorder);
                    pz = ((R - R * cosf(alpha)) / _iMinZorder);
                }
                if(i == (int)_gridSize.width/5*4 && j== (int)_gridSize.height/5*4){
                    //CCLog("min alpha = %f",alpha);
                    if(fabs(alpha) > _fStopAngle){
                        bStop = true;
                    }
                }
            }
			// Set new coords
			_setVertex(CCPoint(i, j), p,_cardBg);
            p.z = pz;
            _setVertex(CCPoint(i, j), p,_cardFr);
		}
	}

    if(bStop){
        _stopCallbackLua();
    }
}


CCGridBase* PageTurn::_getGrid(CCSprite* spr)
{
	//CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
	CCSize size = spr->getContentSize();
    CCRect rect = CCRectMake(0, 0, m_obContentSize.height, m_obContentSize.width);
    //rect =  CCRectApplyAffineTransform(rect, spr->nodeToParentTransform());
    rect = spr->boundingBox();
	auto result = MyGrid3D::create(_gridSize, rect);
	CCDirector::sharedDirector()->setDepthTest(true);
	return result;
}

ccVertex3F PageTurn::_getOriginalVertex(const CCPoint& position, CCNode* node)
{
    if( node == nullptr){
        node = _cardBg;
    }
	MyGrid3D *g = (MyGrid3D*)node->getGrid();
	return g->originalVertex(position);
}

void PageTurn::_setVertex(const CCPoint& position, const ccVertex3F& vertex,CCNode* node)
{
    if( node == nullptr){
        node = _cardBg;
    }

	MyGrid3D *g = (MyGrid3D*)node->getGrid();
	g->setVertex(position, vertex);

    // CCLog("_setVertex");
}

ccVertex3F PageTurn::_getVertex(const CCPoint& position, CCNode* node)
{
    if( node == nullptr){
        node = _cardBg;
    }
    MyGrid3D *g = (MyGrid3D*)node->getGrid();
    return g->vertex(position);
}


bool PageTurn::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent)
{
    CCSize size = getContentSize();
    CCPoint ptTouch = pTouch->getLocation();
    ptTouch = convertToNodeSpace(ptTouch);//转为本地坐标
    ptTouch = ptTouch + getPosition();
    CCRect rect = _cardBg->boundingBox() ;
    rect.origin.x = rect.origin.x - 100;
    rect.origin.y = rect.origin.y - 100;
    rect.size.width = rect.size.width + 200;
    rect.size.height = rect.size.height + 200;
    if(rect.containsPoint(ptTouch)){
        if( _bStop )
        {
            return true;
        }
        if(!_bEnable){
            return true;
        }
        _clickType = 1; //处于begin
        _touchBegin = ptTouch;
        _dValue = 0;
        _fTurnValue = 0;
        
        //存储点击的x,y坐标
        float ddx = size.width/2 + _touchBegin.x - getPositionX();
        float ddy = size.height/2 + _touchBegin.y - getPositionY();
        //计算宽高的10分之1和5分之4
        float width_5_1 = size.width/10 ;
        float height_5_1 = size.height/10;
        float width_5_4 = size.width/5*4;
        float height_5_4 = size.height/5*4;

        CCLOG("pageturn ddx = %f , ddy = %f ,size.width = %f, size.heihgt = %f",ddx, ddy,size.width,size.height);
        if (ddx <= width_5_1 && ddy <= height_5_1 ){//左下到右翻
            _iTurnType = 1;
            CCLog("pageturn_fangxiang 左下到右翻");
        }
        else if (ddx >= width_5_1 && ddx <= width_5_4 && ddy <= height_5_1){
           _iTurnType = 3;
           CCLog("pageturn_fangxiang 从底往上翻");
        }
        else if (ddx >= width_5_4 && ddy <= height_5_1){
            _iTurnType = 2;
            CCLog("pageturn_fangxiang 右下到左翻");
        }
        else if (ddx < width_5_1 && ddy > height_5_1 && ddy < height_5_4){
            _iTurnType = 4;
            CCLog("pageturn_fangxiang 从左中心往右翻");
        }
        else if (ddx >= width_5_4 && ddy > height_5_1 && ddy < height_5_4){
            _iTurnType = 5;
            CCLog("pageturn_fangxiang 从右中心往左翻");
        }

        if (_iTurnType == 0 ) return false;

        return true;
    }
    return false;
}

void PageTurn::ccTouchMoved(CCTouch *pTouch, CCEvent *pEvent)
{
    if( _bStop )
    {
        return;
    }
    CCSize visibleSize = CCDirector::sharedDirector()->getVisibleSize();
    CCSize winSize = CCDirector::sharedDirector()->getWinSize();
    CCSize size = getContentSize();
    CCPoint ptTouch = pTouch->getLocation();
    ptTouch = convertToNodeSpace(ptTouch);//转为本地坐标
    ptTouch = ptTouch + getPosition();
    CCRect rect = _cardBg->boundingBox() ;
    rect.origin.x = rect.origin.x - 100;
    rect.origin.y = rect.origin.y - 100;
    rect.size.width = rect.size.width + 200;
    rect.size.height = rect.size.height + 200;
    
    if(!rect.containsPoint(ptTouch)){
        return ;
    }
    _touchMove = ptTouch;
    
    float dy0 = _touchMove.y - _touchBegin.y;           
    float dx0 = _touchMove.x - _touchBegin.x;



    //获取 x ,y 的偏移量
    float dy = dy0 ;
    float dx = dx0 ;

    float offset = dy;


    switch(_iTurnType){
        case 1:     //从左下角往右翻
        {
            if(dx > dy && dy0 > 0){
                offset = dx;
            }
        } 
        break;

        case 2:     //从右下角往左翻
        {
            if(dx > dy && dy0 > 0){
                offset = dx;
            }
        }
        break;

        case 3:     //从下往上翻
        {
            if(dy0 < 0){
                return;
            }
        }
        break;


        case 4:     //从左(中点)往右翻
        {
            if(dx > 0) {
                offset = dx;
            }else{
                return;
            }
        }
        break;
        case 5:     //从右(中点)往左翻
        {
            if (dx < 0) {
                offset = dx;
            }else{
                return;
            }
        }
        break;
    }

    CCLog("pageturn ccTouchMoved _fTurnValue = %f",offset);

    _clickType = 2; //处于move
    _fTurnValue = offset ;
    
}

void PageTurn::ccTouchEnded(CCTouch *pTouch, CCEvent *pEvent)
{


    CCPoint ptTouch = pTouch->getLocation();
    ptTouch = convertToNodeSpace(ptTouch);//转为本地坐标
    ptTouch = ptTouch + getPosition();
    _touchEnd = ptTouch;


    // _fTurnValue = 0;    //都停止翻转了 就恢复默认值吧........
    _clickType = 0; //处于end

    
    _touchEndCallbackLua();

    _fFinalValue = _fTurnValue;
    //_dValue = 0;
    //_fTurnValue = 0;
    CCLog("pageturn ccTouchEnded");
}

void PageTurn::ccTouchCancelled(CCTouch *pTouch, CCEvent *pEvent)
{
    // _fTurnValue = 0;    //都停止翻转了 就恢复默认值吧........
    _clickType = 0; //处于end

    _touchEndCallbackLua();

    CCLog("pageturn ccTouchCancelled");
}

float PageTurn::getTurnValue()
{
    return _fTurnValue;
}

void PageTurn::showCard()
{
    //停止翻牌
//    MyGrid3D* grid3d = (MyGrid3D*)_cardFr->getGrid();
//    grid3d->calculateVertexPoints();
//    grid3d = (MyGrid3D*)_cardBg->getGrid();
//    grid3d->calculateVertexPoints();
    if(!getStop()){
        setStop(true);
        
    }
    setGridActivie(false);
    _cardFr->setScale(1);
    if(getRotation() == 90){
        setRotation(0);
    }
    _cardBg->setVisible(false);
    _iTurnType = 0;
    _fTurnValue = 0;
    _bShowCard = true;
    _dValue = 0;
}

void PageTurn::setStop(bool bStop)
{
    if(_bStop == bStop){
        return;
    }
    _bStop = bStop;
    if(bStop){
        _dValue = 0;
        _fTurnValue = 0;
        unschedule(_selectorTurn);
    }else{//可翻牌
        _cardBg->setVisible(true);
        _bShowCard = false;
        setGridActivie(true);
        //开个定时器防止翻牌过快
        _selectorTurn = schedule_selector(PageTurn::_autoTurn);
        schedule(_selectorTurn);
    }
}

bool PageTurn::getStop()
{
    return _bStop;
}

int PageTurn::getTurnType()
{
    return _iTurnType;
}

void PageTurn::turnCard(int iType, float offset)
{
    // CCLog("pageturn offset = %f , _iTurnType = %d",offset, iType);

    switch(iType){
        case 1: turnFromLeftBottom(offset); break;      //从左下角往右翻
        case 2: turnFromRightBottom(offset); break;     //从右下角往左翻
        case 3: turnFromMid(offset); break;             //从下往上翻
        case 4: turnFromLeft(offset); break;            //从左(中点)往右翻
        case 5: turnFromRight(offset); break;           //从右(中点)往左翻
    }
}

void PageTurn::setStopCallbackHandler(LUA_FUNCTION handler)
{
    _stopCallbackHandler = handler;
}

void PageTurn::setTouchEndCallbackHandler(LUA_FUNCTION handler)//触摸结束回调函数
{
    __touchEndCallbackHander = handler;
}


void PageTurn::_stopCallbackLua()
{
    // setStop(true);
    if(_stopCallbackHandler > 0){
        CCScriptEngineManager::sharedManager()->getScriptEngine()->
        executeEvent(_stopCallbackHandler, "stopCallback",  NULL, NULL);
    }
    else{
        //showCard();
    }
}

bool PageTurn::getShowCard()
{
    return _bShowCard;
}

void PageTurn::setChangeCallbackHandler(LUA_FUNCTION handler)
{
    _changeCallbackHandler = handler;
}

void PageTurn::_changeCallbackLua()
{
    if(_changeCallbackHandler > 0){
        //CCScriptEngineManager::sharedManager()->getScriptEngine()->
        //executeEvent(_changeCallbackHandler, "changeCallback",  this, NULL);
        CCLuaStack* stack = CCLuaEngine::defaultEngine()->getLuaStack();
        stack->pushInt(_iTurnType);
        stack->pushInt(_dValue);
        stack->executeFunctionByHandler(_changeCallbackHandler, 2);
        stack->clean();
        
    }
}


void PageTurn::_touchEndCallbackLua(){
    if(__touchEndCallbackHander > 0){
        CCLuaStack* pStack = CCLuaEngine::defaultEngine()->getLuaStack();  
        //第一个参数是函数的整数句柄，第二个参数是函数参数个数  
        pStack->executeFunctionByHandler(__touchEndCallbackHander,0);  
        pStack->clean();  
        // CCLOG("call lua function..");  
    }

}

void PageTurn::setScale(float fScale)
{
    if(!_cardBg){
        return;
    }
    if(!_cardFr){
        return;
    }
    CCNode::setScale(fScale);
    if(_bStop){
        return;
    }
    _cardBg->setScale(fScale);
    _cardFr->setScale(fScale);
    _cardFr->setScaleY(-getScaleY());
    CCRect rect = _cardBg->boundingBox();
    MyGrid3D* grid = (MyGrid3D*)_cardBg->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
    grid = (MyGrid3D*)_cardFr->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
}

void PageTurn::setScaleX(float newScaleX)
{
    CCNode::setScaleX(newScaleX);
    if(_bStop){
        return;
    }
    _cardBg->setScaleX(newScaleX);
    _cardFr->setScaleX(newScaleX);
    CCRect rect = _cardBg->boundingBox();
    MyGrid3D* grid = (MyGrid3D*)_cardBg->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
    grid = (MyGrid3D*)_cardFr->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
}

void PageTurn::setScaleY(float newScaleY)
{
    CCNode::setScaleY(newScaleY);
    if(_bStop){
        return;
    }
    _cardBg->setScaleY(newScaleY);
    _cardFr->setScaleY(-getScaleY());
    CCRect rect = _cardBg->boundingBox();
    MyGrid3D* grid = (MyGrid3D*)_cardBg->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
    grid = (MyGrid3D*)_cardFr->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
}

void PageTurn::setRotationX(float fRotationX)
{
    CCNode::setRotationX(fRotationX);
    if(_bStop){
        return;
    }
    _cardBg->setRotationX(fRotationX);
    _cardFr->setRotationX(fRotationX);
    CCRect rect = _cardBg->boundingBox();
    MyGrid3D* grid = (MyGrid3D*)_cardBg->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
    grid = (MyGrid3D*)_cardFr->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
}

void PageTurn::setRotationY(float fRotationY)
{
    CCNode::setRotationY(fRotationY);
    if(_bStop){
        return;
    }
    _cardBg->setRotationY(fRotationY);
    _cardFr->setRotationY(fRotationY);
    CCRect rect = _cardBg->boundingBox();
    MyGrid3D* grid = (MyGrid3D*)_cardBg->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
    grid = (MyGrid3D*)_cardFr->getGrid();
    grid->setGridRect(rect);
    grid->calculateVertexPoints();
}

void PageTurn::_autoTurn(float dt)
{
    // CCLOG("_autoTurn ........");
    if(_bStop){
        return;
    }

    

     // CCLOG("_autoTurn ........222222");

    float turnValue = getTurnValue();
    int turnType = getTurnType();
    float fTemp = 0;
    float rate = 1;


    //翻转的时候, 需要做一些值得兼容对应手指, 这里为临时值
    switch(turnType){
        case 1://从左下角往右翻
        {   
            turnValue = turnValue + __leftBottomOffset;
            rate = __leftBottomRate;
        }
        break;
        case 2://从右下角往左翻
        {   
            turnValue = turnValue + __rightBottomOffset;
            rate = __rightBottomRate;
        }
        break;             
        case 3://从下往上翻
        {
            turnValue = turnValue + __midOffset;
            rate = __midRate;
        }  
        break;             
        case 4://从左(中点)往右翻
        {
            turnValue = turnValue + __leftOffset;
            rate = __leftRate;
        }
        break;
        case 5://从右(中点)往左翻
        {
            turnValue = turnValue + __rightOffset;
            rate = __rightRate;
        }
        break;
    }

    if (_clickType > 0){
        _dValue = turnValue * rate;
    }else{
        //松开状态的时候 自动慢慢变回没翻的状态...
        if (turnValue > 0){
            turnValue -= __backValue;
            if (turnValue < 0) {
                turnValue = 0;
            }
        }else if (turnValue < 0 ) {
            turnValue += __backValue;
            if (turnValue > 0 ){
                turnValue = 0;
            }
        }

        _dValue = turnValue * rate;
        
    }
   
    // CCLOG("pageturn ___dValue %f",_dValue);  
    turnCard(getTurnType(),_dValue);

    if (_clickType <= 0) {
        if (_fTurnValue > 0){
            //恢复的时候, 要实际值去递减, 这里为实际值
            _fTurnValue = _fTurnValue - __backValue;
            if (_fTurnValue < 0) {
                _fTurnValue = 0;
            }
        }else if (_fTurnValue < 0){
            //恢复的时候, 要实际值去递减, 这里为实际值
            _fTurnValue = _fTurnValue + __backValue;
            if (_fTurnValue > 0) {
                _fTurnValue = 0;
            }
        }
       
    }



    _changeCallbackLua();


}


void PageTurn::setBackValue(int backValue)
{
    __backValue = backValue;
}


void PageTurn::setTouchEnable(bool enable)
{
    _bEnable = enable;
}



void PageTurn::setTurnOffset(int turnType ,float rate, int offset)
{
    switch(turnType){
        case 1://从左下角往右翻
            {
                __leftBottomRate = rate;
                __leftBottomOffset = offset;
            };
            break;
        case 2://从右下角往左翻
            {
                __rightBottomRate = rate;
                __rightBottomOffset = offset;
            }
            break;
        case 3://从下往上翻
            {
                __midRate = rate;
                __midOffset = offset;
            }
            break;
        case 4://从左(中点)往右翻
            {
                __leftRate = rate;
                __leftOffset = offset;
            }
            break;
        case 5://从右(中点)往左翻
            {
                __rightRate = rate;
                __rightOffset = offset;
            }
            break;
    }
}