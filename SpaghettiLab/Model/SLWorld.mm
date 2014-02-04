//
//  SLWorld.m
//  SpaghettiLab
//
//  Created by Johannes Ekberg on 2013-10-01.
//  Copyright (c) 2013 MacaroniCode. All rights reserved.
//

#import "SLWorld.h"
#import "SLThing.h"

@implementation SLWorld

- (id)init
{
    if((self = [super init]))
    {
		_things = [[NSMutableArray alloc] init];
		
        _g = SLVector(0, 9.82);
    }
    
    return self;
}

- (void)addThing:(SLThing *)thing
{
	[_things addObject:thing];
	[_delegate world:self didAddThing:thing];
}

- (void)removeThing:(SLThing *)thing
{
	[_things removeObject:thing];
	[_delegate world:self didRemoveThing:thing];
}

- (void)tick:(NSTimeInterval)t
{
    for(SLThing *thing in _things)
	{
		[thing tickBegin:t];
		if(thing.mass != 0)
			[thing applyForce:_g time:t];
		SLVector dPos = [thing tickEnd:t];
		
		//thing.pos += dPos;
		[self attemptMotion:dPos forThing:thing];
	}
}

- (void)attemptMotion:(SLVector &)motion forThing:(SLThing *)thing
{
	thing.pos += motion;
	
	// Check world boundaries
	SLVector min = SLVector(0, 0);
	SLVector max = [_delegate worldBoundary:self] - thing.size;	// Account for the thing's size!
	
	if(thing.pos.y > max.y)
	{
		thing.pos = SLVector(thing.pos.x, max.y);
		thing.v = SLVector(thing.v.x, 0);
	}
	else if(thing.pos.x > max.x)
	{
		thing.pos = SLVector(max.x, thing.pos.y);
		thing.v = SLVector(0, thing.v.y);
	}
	
	if(thing.pos.y < min.y)
	{
		thing.pos = SLVector(thing.pos.x, min.y);
		thing.v = SLVector(thing.v.x, 0);
	}
	else if(thing.pos.x < min.x)
	{
		thing.pos = SLVector(min.x, thing.pos.y);
		thing.v = SLVector(0, thing.v.y);
	}
	
	// Check for collissions
	for (SLThing *otherThing in _things)
	{
		if(thing == otherThing || ![thing collidesWith:otherThing])
			continue;
		
		NSLog(@"THE THINGS ARE COLLIDING");
	}
}

@end
