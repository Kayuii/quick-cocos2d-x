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

#include <spine/SkeletonAnimation.h>
#include <spine/spine-cocos2dx.h>
#include <spine/extension.h>
#include <algorithm>

USING_NS_CC;
using std::min;
using std::max;
using std::vector;

namespace spine {

void animationCallback (spAnimationState* state, int trackIndex, spEventType type, spEvent* event, int loopCount) {
    //CCLOGERROR("animationCallback");
	((SkeletonAnimation*)state->rendererObject)->onAnimationStateEvent(trackIndex, type, event, loopCount);
}

void trackEntryCallback (spAnimationState* state, int trackIndex, spEventType type, spEvent* event, int loopCount) {
	((SkeletonAnimation*)state->rendererObject)->onTrackEntryEvent(trackIndex, type, event, loopCount);
}

typedef struct _TrackEntryListeners {
	StartListener startListener;
	EndListener endListener;
	CompleteListener completeListener;
	EventListener eventListener;
} _TrackEntryListeners;

static _TrackEntryListeners* getListeners (spTrackEntry* entry) {
	if (!entry->rendererObject) {
		entry->rendererObject = NEW(spine::_TrackEntryListeners);
		entry->listener = trackEntryCallback;
	}
	return (_TrackEntryListeners*)entry->rendererObject;
}

void disposeTrackEntry (spTrackEntry* entry) {
	if (entry->rendererObject) FREE(entry->rendererObject);
	_spTrackEntry_dispose(entry);
}

//

SkeletonAnimation* SkeletonAnimation::createWithData (spSkeletonData* skeletonData) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonData);
	node->autorelease();
    //m_pDispatchTable = NULL;
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithFile (const char* skeletonDataFile, spAtlas* atlas, float scale) {
	SkeletonAnimation* node = new SkeletonAnimation(skeletonDataFile, atlas, scale);
	node->autorelease();
     //m_pDispatchTable = NULL;
	return node;
}

SkeletonAnimation* SkeletonAnimation::createWithFile (const char* skeletonDataFile, const char* atlasFile, float scale) {
    SkeletonAnimation* node;
    char key[128];
    sprintf(key,"%s%.2f",skeletonDataFile,scale );
    
    if(isExistSkeletonDataInCache(key))
    {
        node = createFromCache(key);
        //CCLOGERROR("---------createFromCache:%s",key);
    }
    else
    {
        spSkeletonData* data = readSkeletonDataToCache(key, skeletonDataFile, atlasFile,scale);
        node = new SkeletonAnimation(data);
        //CCLOGERROR("---------new SkeletonAnimation");
        node->autorelease();
    }

    //m_pDispatchTable = NULL;
	return node;
}

void SkeletonAnimation::initialize () {
	ownsAnimationStateData = true;
	state = spAnimationState_create(spAnimationStateData_create(skeleton->data));
	state->rendererObject = this;
	state->listener = animationCallback;

	_spAnimationState* stateInternal = (_spAnimationState*)state;
	stateInternal->disposeTrackEntry = disposeTrackEntry;
    m_pDispatchTable = new CCDictionary();
    m_mapHandleOfSpineEvent.clear();
}

SkeletonAnimation::SkeletonAnimation (spSkeletonData *skeletonData)
		: SkeletonRenderer(skeletonData) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const char* skeletonDataFile, spAtlas* atlas, float scale)
		: SkeletonRenderer(skeletonDataFile, atlas, scale) {
	initialize();
}

SkeletonAnimation::SkeletonAnimation (const char* skeletonDataFile, const char* atlasFile, float scale)
		: SkeletonRenderer(skeletonDataFile, atlasFile, scale) {
	initialize();
}

SkeletonAnimation::~SkeletonAnimation () {
     //CCLOGERROR("~SkeletonAnimation");
	if (ownsAnimationStateData) spAnimationStateData_dispose(state->data);
	spAnimationState_dispose(state);
}

void SkeletonAnimation::update (float deltaTime) {
	super::update(deltaTime);

	deltaTime *= timeScale;
	spAnimationState_update(state, deltaTime);
	spAnimationState_apply(state, skeleton);
	spSkeleton_updateWorldTransform(skeleton);
}

void SkeletonAnimation::setAnimationStateData (spAnimationStateData* stateData) {
	CCAssert(stateData, "stateData cannot be null.");

	if (ownsAnimationStateData) spAnimationStateData_dispose(state->data);
	spAnimationState_dispose(state);

	ownsAnimationStateData = false;
	state = spAnimationState_create(stateData);
	state->rendererObject = this;
	state->listener = animationCallback;
}

void SkeletonAnimation::setMix (const char* fromAnimation, const char* toAnimation, float duration) {
	spAnimationStateData_setMixByName(state->data, fromAnimation, toAnimation, duration);
}

spTrackEntry* SkeletonAnimation::setAnimation (int trackIndex, const char* name, bool loop) {
	spAnimation* animation = spSkeletonData_findAnimation(skeleton->data, name);
	if (!animation) {
		CCLog("Spine: Animation not found: %s", name);
		return 0;
	}
	return spAnimationState_setAnimation(state, trackIndex, animation, loop);
}

spTrackEntry* SkeletonAnimation::addAnimation (int trackIndex, const char* name, bool loop, float delay) {
	spAnimation* animation = spSkeletonData_findAnimation(skeleton->data, name);
	if (!animation) {
		CCLog("Spine: Animation not found: %s", name);
		return 0;
	}
	return spAnimationState_addAnimation(state, trackIndex, animation, loop, delay);
}

spTrackEntry* SkeletonAnimation::getCurrent (int trackIndex) { 
	return spAnimationState_getCurrent(state, trackIndex);
}

void SkeletonAnimation::clearTracks () {
	spAnimationState_clearTracks(state);
}

void SkeletonAnimation::clearTrack (int trackIndex) {
	spAnimationState_clearTrack(state, trackIndex);
}

void SkeletonAnimation::onAnimationStateEvent (int trackIndex, spEventType type, spEvent* event, int loopCount) {
	switch (type) {
        //CCLOGERROR("------------------SP_ANIMATION %d",type);
	case SP_ANIMATION_START:
             //CCLOGERROR("start!!!!!");
            this->sendActionsForControlEvents(CCSpineAnimationStart);
		if (startListener) startListener(trackIndex);
            
		break;
	case SP_ANIMATION_END:
            //CCLOGERROR("end!!!!!");
            this->sendActionsForControlEvents(CCSpineAnimationEnd);
            if(endListener)
            {
                //CCLOGERROR("listener not nil !!!!!%d",trackIndex);
            }
		if (endListener) endListener(trackIndex);
		break;
	case SP_ANIMATION_COMPLETE:
            this->sendActionsForControlEvents(CCSpineAnimationCompelete);
		if (completeListener) completeListener(trackIndex, loopCount);
		break;
	case SP_ANIMATION_EVENT:
		if (eventListener) eventListener(trackIndex, event);
		break;
	}
}

void SkeletonAnimation::onTrackEntryEvent (int trackIndex, spEventType type, spEvent* event, int loopCount) {
     //CCLOGERROR("------------------SP_ANIMATION %d",type);
	spTrackEntry* entry = spAnimationState_getCurrent(state, trackIndex);
	if (!entry->rendererObject) return;
	_TrackEntryListeners* listeners = (_TrackEntryListeners*)entry->rendererObject;
	switch (type) {
        //CCLOGERROR("------------------SP_ANIMATION %d",type);
	case SP_ANIMATION_START:
		if (listeners->startListener) listeners->startListener(trackIndex);
		break;
	case SP_ANIMATION_END:
		if (listeners->endListener) listeners->endListener(trackIndex);
		break;
	case SP_ANIMATION_COMPLETE:
		if (listeners->completeListener) listeners->completeListener(trackIndex, loopCount);
		break;
	case SP_ANIMATION_EVENT:
		if (listeners->eventListener) listeners->eventListener(trackIndex, event);
		break;
	}
}

void SkeletonAnimation::setStartListener (spTrackEntry* entry, StartListener listener) {
	getListeners(entry)->startListener = listener;
}

void SkeletonAnimation::setEndListener (spTrackEntry* entry, EndListener listener) {
    //CCLOGERROR("------------------setEndListener");
	getListeners(entry)->endListener = listener;
}

void SkeletonAnimation::setCompleteListener (spTrackEntry* entry, CompleteListener listener) {
	getListeners(entry)->completeListener = listener;
}

void SkeletonAnimation::setEventListener (spTrackEntry* entry, spine::EventListener listener) {
	getListeners(entry)->eventListener = listener;
}
    //////////
    void SkeletonAnimation::sendActionsForControlEvents(CCSpineEvent spineEvents){
        // For each control events
        for (int i = 0; i < 3; i++)
        {
            // If the given controlEvents bitmask contains the curent event
            if ((spineEvents & (1 << i)))
            {
                // Call invocations
                // <CCInvocation*>
                CCArray* invocationList = this->dispatchListforControlEvent(1<<i);
                CCObject* pObj = NULL;
                CCARRAY_FOREACH(invocationList, pObj)
                {
                    cocos2d::extension::CCInvocation* invocation = ( cocos2d::extension::CCInvocation*)pObj;
                    invocation->invoke(this);
                }
                //Call ScriptFunc
                int nHandler = this->getHandleOfSpineEvent(spineEvents);
                if (-1 != nHandler)
                {
                    CCScriptEngineManager::sharedManager()->getScriptEngine()->executeEvent(nHandler,"",this);
                }
            }
        }

    }
    
    void SkeletonAnimation::addTargetWithActionForControlEvent(CCObject* target, cocos2d::extension::SEL_CCSpineHandler action, CCSpineEvent spineEvent){
        // Create the invocation object
        cocos2d::extension::CCInvocation *invocation = cocos2d::extension::CCInvocation::create(target, action, spineEvent);
        
        // Add the invocation into the dispatch list for the given control event
        CCArray* eventInvocationList = this->dispatchListforControlEvent(spineEvent);
        eventInvocationList->addObject(invocation);
    }
    
    void  SkeletonAnimation::addTargetWithActionForControlEvents(CCObject* target, cocos2d::extension::SEL_CCSpineHandler action, CCSpineEvent spineEvent){
        // For each control events
        for (int i = 0; i < 3; i++)
        {
            // If the given controlEvents bitmask contains the curent event
            if ((spineEvent & (1 << i)))
            {
                this->addTargetWithActionForControlEvent(target, action, 1<<i);
            }
        }

        
    }
   void SkeletonAnimation::removeTargetWithActionForControlEvent(CCObject* target, cocos2d::extension::SEL_CCSpineHandler action, CCSpineEvent spineEvent)   {
        // Retrieve all invocations for the given control event
        //<CCInvocation*>
        CCArray *eventInvocationList = this->dispatchListforControlEvent(spineEvent);
        
        //remove all invocations if the target and action are null
        //TODO: should the invocations be deleted, or just removed from the array? Won't that cause issues if you add a single invocation for multiple events?
        bool bDeleteObjects=true;
        if (!target && !action)
        {
            //remove objects
            eventInvocationList->removeAllObjects();
        }
        else
        {
            //normally we would use a predicate, but this won't work here. Have to do it manually
            CCObject* pObj = NULL;
            CCARRAY_FOREACH(eventInvocationList, pObj)
            {
                cocos2d::extension::CCInvocation *invocation = (cocos2d::extension::CCInvocation*)pObj;
                bool shouldBeRemoved=true;
                if (target)
                {
                    shouldBeRemoved=(target==invocation->getTarget());
                }
                if (action)
                {
                    shouldBeRemoved=(shouldBeRemoved && (action==invocation->getAction()));
                }
                // Remove the corresponding invocation object
                if (shouldBeRemoved)
                {
                    eventInvocationList->removeObject(invocation, bDeleteObjects);
                }
            }
        }
    }
    
    void  SkeletonAnimation::removeTargetWithActionForControlEvents(CCObject* target, cocos2d::extension::SEL_CCSpineHandler action, CCSpineEvent spineEvent){
        // For each control events
        for (int i = 0; i < 3; i++)
        {
            // If the given controlEvents bitmask contains the curent event
            if ((spineEvent & (1 << i)))
            {
                this->removeTargetWithActionForControlEvent(target, action, 1<<i);
            }
        }
    }
    
    CCArray* SkeletonAnimation::dispatchListforControlEvent(CCSpineEvent spineEvent)
    {
        CCArray* invocationList = static_cast<CCArray*>(m_pDispatchTable->objectForKey((int)spineEvent));
        
        // If the invocation list does not exist for the  dispatch table, we create it
        if (invocationList == NULL)
        {
            invocationList = CCArray::createWithCapacity(1);
            m_pDispatchTable->setObject(invocationList, spineEvent);
        }
        return invocationList;
    }

    void SkeletonAnimation::addHandleOfSpineEvent(int nFunID, CCSpineEvent spineEvent) {
        m_mapHandleOfSpineEvent[spineEvent] = nFunID;
        //m_mapHandleOfSpineEvent.insert(std::map<int, int> :: value_type(spineEvent, nFunID));
        //CCLOGERROR("addHandle---%d",m_mapHandleOfSpineEvent.size());
    }
    void SkeletonAnimation::removeHandleOfSpineEvent(CCSpineEvent spineEvent ){
        std::map<int,int>::iterator Iter = m_mapHandleOfSpineEvent.find(spineEvent);
        if(m_mapHandleOfSpineEvent.end() != Iter)
        {
            m_mapHandleOfSpineEvent.erase(Iter);
        }
    }
    int SkeletonAnimation::getHandleOfSpineEvent(CCSpineEvent spineEvent ){
        std::map<int,int>::iterator Iter = m_mapHandleOfSpineEvent.find(spineEvent);
        if(m_mapHandleOfSpineEvent.end() != Iter)
        {
            //CCLOGERROR("getHandle---%d", Iter->second);
            return Iter->second;
        }
        return -1;
    }
    
    std::map<std::string, SkeletonAnimation::SkeletonDataInCache> SkeletonAnimation::_all_skeleton_data_cache; //初始化静态成员
    SkeletonAnimation* SkeletonAnimation::createFromCache(const std::string& skeletonDataKeyName)
    {
        if (spSkeletonData* skeleton_data = getSkeletonDataFromCache(skeletonDataKeyName)){
            SkeletonAnimation* node = new SkeletonAnimation(skeleton_data);
            node->autorelease();
            return node;
        }
        
        return nullptr;
    }
    
    spSkeletonData* SkeletonAnimation::readSkeletonDataToCache(const std::string& skeletonDataKeyName, const std::string& skeletonDataFile, const std::string& atlasFile, float scale /*= 1*/)
    {
        ItSkeletonData it = _all_skeleton_data_cache.find(skeletonDataKeyName);
        
        if (it == _all_skeleton_data_cache.end()){
            SkeletonDataInCache skeleton_data_in_cache;
            skeleton_data_in_cache._atlas = nullptr;
            skeleton_data_in_cache._skeleton_data = nullptr;
            
            skeleton_data_in_cache._atlas = spAtlas_createFromFile(atlasFile.c_str(), 0);
            //CCASSERT(skeleton_data_in_cache._atlas, "readSkeletonDataToCachereading Error  atlas file.");
            
            spSkeletonJson* json = spSkeletonJson_create(skeleton_data_in_cache._atlas);
            json->scale = scale;
            skeleton_data_in_cache._skeleton_data = spSkeletonJson_readSkeletonDataFile(json, skeletonDataFile.c_str());
            //CCASSERT(skeleton_data_in_cache._skeleton_data, json->error ? json->error : "readSkeletonDataToCache Error reading skeleton data file.");
            spSkeletonJson_dispose(json);
            
            if (skeleton_data_in_cache._atlas && skeleton_data_in_cache._skeleton_data){
                _all_skeleton_data_cache[skeletonDataKeyName] = skeleton_data_in_cache;
                
                return skeleton_data_in_cache._skeleton_data;
            }
            else{ //错误处理，释放创建的资源
                if (skeleton_data_in_cache._skeleton_data){
                    spSkeletonData_dispose(skeleton_data_in_cache._skeleton_data);
                }
                
                if (skeleton_data_in_cache._atlas){
                    spAtlas_dispose(skeleton_data_in_cache._atlas);
                }
            }
        }
        
        return nullptr;
    }
    
    spSkeletonData* SkeletonAnimation::getSkeletonDataFromCache(const std::string& skeletonDataKeyName)
    {
        ItSkeletonData it = _all_skeleton_data_cache.find(skeletonDataKeyName);
        if (it != _all_skeleton_data_cache.end()){
            return it->second._skeleton_data;
        }
        
        return nullptr;
    }
    
    bool SkeletonAnimation::removeSkeletonData(const std::string& skeletonDataKeyName)
    {
        ItSkeletonData it = _all_skeleton_data_cache.find(skeletonDataKeyName);
        if (it != _all_skeleton_data_cache.end()){
            if (it->second._skeleton_data) spSkeletonData_dispose(it->second._skeleton_data);
            if (it->second._atlas) spAtlas_dispose(it->second._atlas);
            
            _all_skeleton_data_cache.erase(it);
            return true;
        }
        
        return false;
    }
    
    void SkeletonAnimation::removeAllSkeletonData()
    {
        for (ItSkeletonData it = _all_skeleton_data_cache.begin(); it != _all_skeleton_data_cache.end(); ++it){
            if (it->second._skeleton_data) spSkeletonData_dispose(it->second._skeleton_data);
            if (it->second._atlas) spAtlas_dispose(it->second._atlas);
        }
        
        _all_skeleton_data_cache.clear();
    }
    
    bool SkeletonAnimation::isExistSkeletonDataInCache(const std::string& skeletonDataKeyName)
    {
        ItSkeletonData it = _all_skeleton_data_cache.find(skeletonDataKeyName);
        if (it != _all_skeleton_data_cache.end()){
            return true;
        }
        
        return false;
    }
    
}
