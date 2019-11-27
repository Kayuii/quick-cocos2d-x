
#ifndef __EFFECTS_MYCCGRID_H__
#define __EFFECTS_MYCCGRID_H__

#include "cocos2d.h"

using namespace cocos2d;


class  MyGrid3D : public CCGridBase
{
public:
    MyGrid3D();
    ~MyGrid3D(void);

    /** returns the vertex at a given position */
    ccVertex3F vertex(const CCPoint& pos);
    /** returns the original (non-transformed) vertex at a given position */
    ccVertex3F originalVertex(const CCPoint& pos);
    /** sets a new vertex at a given position */
    void setVertex(const CCPoint& pos, const ccVertex3F& vertex);

    virtual void blit(void);//渲染顶点
    virtual void reuse(void);
    virtual void calculateVertexPoints(void);
public:
    /** create one Grid */
    static MyGrid3D* create(const CCSize& gridSize, CCTexture2D *pTexture, bool bFlipped);
    /** create one Grid */
    static MyGrid3D* create(const CCSize& gridSize);
	static MyGrid3D* create(const CCSize& gridSize, CCRect rect);
    GLvoid* getTexCoordinates(){return m_pTexCoordinates;}
    void setTexCoordinate(GLvoid* texCoord){m_pTexCoordinates = texCoord;}
    GLvoid* getVertices(){return m_pVertices;}
    void setVertices(GLvoid* texCoord){m_pVertices = texCoord;}
    void setGridRect(CCRect& rect);
    CCRect getGridRect();
protected:
    GLvoid *m_pTexCoordinates;
    GLvoid *m_pVertices;
    GLvoid *m_pOriginalVertices;
    GLushort *m_pIndices;
	CCRect _gridRect;
    CCTexture2D* _myTex;
};



#endif // __EFFECTS_CCGRID_H__
