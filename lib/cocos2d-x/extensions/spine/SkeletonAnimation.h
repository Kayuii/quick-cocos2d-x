/******************************************************************************
 * Spine Runtimes Software License
 * Version 2.3
 * 
 * Copyright (c) 2013-2015, Esoteric Software
 * All rights reserved.
 * 
 * You are granted a perpetual, non-exclusive, non-sublicensable and
 * non-transferable license to use, install, execute and perform the Spine
 * Runtimes Software (the "Software") and derivative works solely for personal
 * or internal use. Without the written permission of Esoteric Software (see
 * Section 2 of the Spine Software License Agreement), you may not (a) modify,
 * translate, adapt or otherwise create derivative works, improvements of the
 * Software or develop new applications using the Software or (b) remove,
 * delete, alter or obscure any trademarks or any copyright, trademark, patent
 * or other intellectual property or proprietary rights notices on or in the
 * Software, including any copy thereof. Redistributions in binary or source
 * form must include this license and terms.
 * 
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

#ifndef SPINE_SKELETONANIMATION_H_
#define SPINE_SKELETONANIMATION_H_

#include <spine/spine.h>
#include <spine/SkeletonRenderer.h>
#include "cocos2d.h"
#include "CCInvocation.h"
using namespace cocos2d;
enum
{
    CCSpineAnimationStart = 1 << 0,
    CCSpineAnimationEnd = 1 << 1,
    CCSpineAnimationCompelete = 1 << 2
};
namespace spine {
    //class cocos2d::extension::CCInvocation;
    
    typedef unsigned int CCSpineEvent;



    
typedef std::function<void(int trackIndex)> StartListener;
typedef std::function<void(int trackIndex)> EndListener;
typedef std::function<void(int trackIndex, int loopCount)> CompleteListener;
typedef std::function<void(int trackIndex, spEvent* event)> EventListener;

/** Draws an animated skeleton, providing an AnimationState for applying one or more animations and queuing animations to be
  * played later. */
class SkeletonAnimation: public SkeletonRenderer {
public:
	spAnimationState* state;

	static SkeletonAnimation* createWithData (spSkeletonData* skeletonData);
	static SkeletonAnimation* createWithFile (const char* skeletonDataFile, spAtlas* atlas, float scale = 0);
	static SkeletonAnimation* createWithFile (const char* skeletonDataFile, const char* atlasFile, float scale = 0);

	SkeletonAnimation (spSkeletonData* skeletonData);
	SkeletonAnimation (const char* skeletonDataFile, spAtlas* atlas, float scale = 0);
	SkeletonAnimation (const char* skeletonDataFile, const char* atlasFile, float scale = 0);

	virtual ~SkeletonAnimation ();

	virtual void update (float deltaTime);

	void setAnimationStateData (spAnimationStateData* stateData);
	void setMix (const char* fromAnimation, const char* toAnimation, float duration);

	spTrackEntry* setAnimation (int trackIndex, const char* name, bool loop);
	spTrackEntry* addAnimation (int trackIndex, const char* name, bool loop, float delay = 0);
	spTrackEntry* getCurrent (int trackIndex = 0);
	void clearTracks ();
	void clearTrack (int trackIndex = 0);

	StartListener startListener;
	EndListener endListener;
	CompleteListener completeListener;
	EventListener eventListener;
	void setStartListener (spTrackEntry* entry, StartListener listener);
	void setEndListener (spTrackEntry* entry, EndListener listener);
	void setCompleteListener (spTrackEntry* entry, CompleteListener listener);
	void setEventListener (spTrackEntry* entry, EventListener listener);

	virtual void onAnimationStateEvent (int trackIndex, spEventType type, spEvent* event, int loopCount);
	virtual void onTrackEntryEvent (int trackIndex, spEventType type, spEvent* event, int loopCount);
    
    void sendActionsForControlEvents(CCSpineEvent spineEvents);
    
    void addTargetWithActionForControlEvent(CCObject* target, cocos2d::extension::SEL_CCSpineHandler action, CCSpineEvent spineEvent);
    void removeTargetWithActionForControlEvent(CCObject* target, cocos2d::extension::SEL_CCSpineHandler action, CCSpineEvent spineEvent);
   //sss
    void addTargetWithActionForControlEvents(CCObject* target, cocos2d::extension::SEL_CCSpineHandler action, CCSpineEvent spineEvent);
    void removeTargetWithActionForControlEvents(CCObject* target, cocos2d::extension::SEL_CCSpineHandler action, CCSpineEvent spineEvent);
    /**
     *  @js NA
     */
    void addHandleOfSpineEvent(int nFunID,CCSpineEvent spineEvent);
    /**
     *  @js NA
     */
    void removeHandleOfSpineEvent(CCSpineEvent spineEvent);
    private:
    int  getHandleOfSpineEvent(CCSpineEvent spineEvent);
    private:
    std::map<int,int> m_mapHandleOfSpineEvent;
    
    //
    //从缓存中创建Animation
    static SkeletonAnimation* createFromCache(const std::string& skeletonDataKeyName);
    
    //将文件读入到cache中(skeletonDataKeyName参数为自定义的骨骼数据名称)
    static spSkeletonData* readSkeletonDataToCache(const std::string& skeletonDataKeyName, const std::string& skeletonDataFile, const std::string& atlasFile, float scale = 1);
    
    //从cache中得到skeletonData(skeletonDataKeyName参数为自定义的骨骼数据名称)
    static spSkeletonData* getSkeletonDataFromCache(const std::string& skeletonDataKeyName);
    
    //从cache中删除skeletonData(skeletonDataKeyName参数为自定义的骨骼数据名称)
    static bool removeSkeletonData(const std::string& skeletonDataKeyName);
    
    //清理所有skeletonData
    static void removeAllSkeletonData();
    
    //是否在cache中存在对应的骨骼数据skeletonData
    static bool isExistSkeletonDataInCache(const std::string& skeletonDataKeyName);
private:
    struct SkeletonDataInCache{
        spSkeletonData* _skeleton_data; //记录骨骼数据
        spAtlas* _atlas; //记录对应图片块信息
    };
    typedef std::map<std::string, SkeletonDataInCache>::iterator ItSkeletonData;
    static std::map<std::string, SkeletonDataInCache> _all_skeleton_data_cache; //记录所有的skeletonData缓冲区
protected:
	SkeletonAnimation ();
     cocos2d::extension::CCInvocation* invocationWithTargetAndActionForControlEvent(CCObject* target, cocos2d::extension::SEL_CCSpineHandler  action, CCSpineEvent controlEvent);
     cocos2d::CCArray* dispatchListforControlEvent(CCSpineEvent spineEvent);

private:
	typedef SkeletonRenderer super;
	bool ownsAnimationStateData;
    cocos2d::CCDictionary* m_pDispatchTable;
	void initialize ();
};

}

#endif /* SPINE_SKELETONANIMATION_H_ */
