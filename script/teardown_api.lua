
---@param command string
function Command(command, ...) end

---@param quat table
---@return string
function QuatStr(quat) end

---@param transform table
---@return string
function TransformStr(transform) end

---@param vector table
---@return string
function VecStr(vector) end

---@param file string
---@return boolean
function HasFile(file) end

function init() end

---@param dt number
function tick(dt) end

---@param dt number
function update(dt) end

---@param dt number
function draw(dt) end

function handleCommand() end

--Autocompletion for the Teardown Lua API for VSCode. To use this, place teardown_api.lua in your mod's root folder and install the Lua extension: https://marketplace.visualstudio.com/items?itemName=sumneko.lua
--teardown_api.lua
---@param name string Parameter name
---@param default number Default parameter value
---@return number value Parameter value
function GetIntParam(name, default) end
---@param name string Parameter name
---@param default number Default parameter value
---@return number value Parameter value
function GetFloatParam(name, default) end
---@param name string Parameter name
---@param default boolean Default parameter value
---@return boolean value Parameter value
function GetBoolParam(name, default) end
---@param name string Parameter name
---@param default string Default parameter value
---@return string value Parameter value
function GetStringParam(name, default) end
---@return string version Dot separated string of current version of the game
function GetVersion() end
---@param version string Reference version
---@return boolean match True if current version is at least provided one
function HasVersion(version) end
---Returns running time of this script. If called from update, this returns the simulated time, otherwise it returns wall time.
---@return number time The time in seconds since level was started
function GetTime() end
---Returns timestep of the last frame. If called from update, this returns the simulation time step, which is always one 60th of a second (0.0166667). If called from tick or draw it returns the actual time since last frame.
---@return number dt The timestep in seconds
function GetTimeStep() end
---@return string name Name of last pressed key, empty if no key is pressed
function InputLastPressedKey() end
---@param input string The input identifier
---@return boolean pressed True if input was pressed during last frame
function InputPressed(input) end
---@param input string The input identifier
---@return boolean pressed True if input was released during last frame
function InputReleased(input) end
---@param input string The input identifier
---@return boolean pressed True if input is currently held down
function InputDown(input) end
---@param input string The input identifier
---@return number value Depends on input type
function InputValue(input) end
---Set value of a number variable in the global context with an optional transition. If a transition is provided the value will animate from current value to the new value during the transition time. Transition can be one of the following:
---@param variable string Name of number variable in the global context
---@param value number The new value
---@param transition string [optional] Transition type. See description.
---@param time number [optional] Transition time (seconds)
function SetValue(variable, value, transition, time) end
---Calling this function will add a button on the bottom bar when the game is paused. Use this as a way to bring up mod settings or other user interfaces while the game is running. Call this function every frame from the tick function for as long as the pause menu button should still be visible.
---@param title string Text on button
---@return boolean clicked True if clicked, false otherwise
function PauseMenuButton(title) end
---Start a level
---@param mission string An identifier of your choice
---@param path string Path to level XML file
---@param layers string [optional] Active layers. Default is no layers.
---@param passThrough boolean [optional] If set, loading screen will have no text and music will keep playing
function StartLevel(mission, path, layers, passThrough) end
---Set paused state of the game
---@param paused boolean True if game should be paused
function SetPaused(paused) end
---Restart level
function Restart() end
---Go to main menu
function Menu() end
---Remove registry node, including all child nodes.
---@param key string Registry key to clear
function ClearKey(key) end
---List all child keys of a registry node.
---@param parent string The parent registry key
---@return table children Indexed table of strings with child keys
function ListKeys(parent) end
---Returns true if the registry contains a certain key
---@param key string Registry key
---@return boolean exists True if key exists
function HasKey(key) end
---@param key string Registry key
---@param value number Desired value
function SetInt(key, value) end
---@param key string Registry key
---@return number value Integer value of registry node or zero if not found
function GetInt(key) end
---@param key string Registry key
---@param value number Desired value
function SetFloat(key, value) end
---@param key string Registry key
---@return number value Float value of registry node or zero if not found
function GetFloat(key) end
---@param key string Registry key
---@param value boolean Desired value
function SetBool(key, value) end
---@param key string Registry key
---@return boolean value Boolean value of registry node or false if not found
function GetBool(key) end
---@param key string Registry key
---@param value string Desired value
function SetString(key, value) end
---@param key string Registry key
---@return string value String value of registry node or "" if not found
function GetString(key) end
---Create new vector and optionally initializes it to the provided values. A Vec is equivalent to a regular lua table with three numbers.
---@param x number [optional] X value
---@param y number [optional] Y value
---@param z number [optional] Z value
---@return table vec New vector
function Vec(x, y, z) end
---Vectors should never be assigned like regular numbers. Since they are implemented with lua tables assignment means two references pointing to the same data. Use this function instead.
---@param org table A vector
---@return table new Copy of org vector
function VecCopy(org) end
---@param vec table A vector
---@return number length Length (magnitude) of the vector
function VecLength(vec) end
---If the input vector is of zero length, the function returns {0,0,1}
---@param vec table A vector
---@return table norm A vector of length 1.0
function VecNormalize(vec) end
---@param vec table A vector
---@param scale number A scale factor
---@return table norm A scaled version of input vector
function VecScale(vec, scale) end
---@param a table Vector
---@param b table Vector
---@return table c New vector with sum of a and b
function VecAdd(a, b) end
---@param a table Vector
---@param b table Vector
---@return table c New vector representing a-b
function VecSub(a, b) end
---@param a table Vector
---@param b table Vector
---@return number c Dot product of a and b
function VecDot(a, b) end
---@param a table Vector
---@param b table Vector
---@return table c Cross product of a and b (also called vector product)
function VecCross(a, b) end
---@param a table Vector
---@param b table Vector
---@param t number fraction (usually between 0.0 and 1.0)
---@return table c Linearly interpolated vector between a and b, using t
function VecLerp(a, b, t) end
---Create new quaternion and optionally initializes it to the provided values. Do not attempt to initialize a quaternion with raw values unless you know what you are doing. Use QuatEuler or QuatAxisAngle instead. If no arguments are given, a unit quaternion will be created: {0, 0, 0, 1}. A quaternion is equivalent to a regular lua table with four numbers.
---@param x number [optional] X value
---@param y number [optional] Y value
---@param z number [optional] Z value
---@param w number [optional] W value
---@return table quat New quaternion
function Quat(x, y, z, w) end
---Quaternions should never be assigned like regular numbers. Since they are implemented with lua tables assignment means two references pointing to the same data. Use this function instead.
---@param org table Quaternion
---@return table new Copy of org quaternion
function QuatCopy(org) end
---Create a quaternion representing a rotation around a specific axis
---@param axis table Rotation axis, unit vector
---@param angle number Rotation angle in degrees
---@return table quat New quaternion
function QuatAxisAngle(axis, angle) end
---Create quaternion using euler angle notation. The order of applied rotations uses the "NASA standard aeroplane" model:
---@param x number Angle around X axis in degrees, sometimes also called roll or bank
---@param y number Angle around Y axis in degrees, sometimes also called yaw or heading
---@param z number Angle around Z axis in degrees, sometimes also called pitch or attitude
---@return table quat New quaternion
function QuatEuler(x, y, z) end
---Return euler angles from quaternion. The order of rotations uses the "NASA standard aeroplane" model:
---@param quat table Quaternion
---@return number z Angle around Z axis in degrees, sometimes also called pitch or attitude
function GetQuatEuler(quat) end
---Create a quaternion pointing the negative Z axis (forward) towards a specific point, keeping the Y axis upwards. This is very useful for creating camera transforms.
---@param eye table Vector representing the camera location
---@param target table Vector representing the point to look at
---@return table quat New quaternion
function QuatLookAt(eye, target) end
---Spherical, linear interpolation between a and b, using t. This is very useful for animating between two rotations.
---@param a table Quaternion
---@param b table Quaternion
---@param t number fraction (usually between 0.0 and 1.0)
---@return table c New quaternion
function QuatSlerp(a, b, t) end
---Rotate one quaternion with another quaternion. This is mathematically equivalent to c = a * b using quaternion multiplication.
---@param a table Quaternion
---@param b table Quaternion
---@return table c New quaternion
function QuatRotateQuat(a, b) end
---Rotate a vector by a quaternion
---@param a table Quaternion
---@param vec table Vector
---@return table vec Rotated vector
function QuatRotateVec(a, vec) end
---A transform is a regular lua table with two entries: pos and rot, a vector and quaternion representing transform position and rotation.
---@param pos table [optional] Vector representing transform position
---@param rot table [optional] Quaternion representing transform rotation
---@return table transform New transform
function Transform(pos, rot) end
---Transforms should never be assigned like regular numbers. Since they are implemented with lua tables assignment means two references pointing to the same data. Use this function instead.
---@param org table Transform
---@return table new Copy of org transform
function TransformCopy(org) end
---Transform child transform out of the parent transform. This is the opposite of TransformToLocalTransform.
---@param parent table Transform
---@param child table Transform
---@return table transform New transform
function TransformToParentTransform(parent, child) end
---Transform one transform into the local space of another transform. This is the opposite of TransformToParentTransform.
---@param parent table Transform
---@param child table Transform
---@return table transform New transform
function TransformToLocalTransform(parent, child) end
---Transfom vector v out of transform t only considering rotation.
---@param t table Transform
---@param v table Vector
---@return table r Transformed vector
function TransformToParentVec(t, v) end
---Transfom vector v into transform t only considering rotation.
---@param t table Transform
---@param v table Vector
---@return table r Transformed vector
function TransformToLocalVec(t, v) end
---Transfom position p out of transform t.
---@param t table Transform
---@param p table Vector representing position
---@return table r Transformed position
function TransformToParentPoint(t, p) end
---Transfom position p into transform t.
---@param t table Transform
---@param p table Vector representing position
---@return table r Transformed position
function TransformToLocalPoint(t, p) end
---@param handle number Entity handle
---@param tag string Tag name
---@param value string [optional] Tag value
function SetTag(handle, tag, value) end
---Remove tag from an entity. If the tag had a value it is removed too.
---@param handle number Entity handle
---@param tag string Tag name
function RemoveTag(handle, tag) end
---@param handle number Entity handle
---@param tag string Tag name
---@return boolean exists Returns true if entity has tag
function HasTag(handle, tag) end
---@param handle number Entity handle
---@param tag string Tag name
---@return string value Returns the tag value, if any. Empty string otherwise.
function GetTagValue(handle, tag) end
---All entities can have an associated description. For bodies and shapes this can be provided through the editor. This function retrieves that description.
---@param handle number Entity handle
---@return string description The description string
function GetDescription(handle) end
---All entities can have an associated description. The description for bodies and shapes will show up on the HUD when looking at them.
---@param handle number Entity handle
---@param description string The description string
function SetDescription(handle, description) end
---Remove an entity from the scene. All entities owned by this entity will also be removed.
---@param handle number Entity handle
function Delete(handle) end
---@param handle number Entity handle
---@return boolean exists Returns true if the entity pointed to by handle still exists
function IsHandleValid(handle) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return number handle Handle to first MainBody with specified tag or zero if not found
function FindBody(tag, global) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return table list Indexed table with handles to all bodies with specified tag
function FindBodies(tag, global) end
---@param handle number MainBody handle
---@return table transform Transform of the MainBody
function GetBodyTransform(handle) end
---@param handle number MainBody handle
---@param transform table Desired transform
function SetBodyTransform(handle, transform) end
---@param handle number MainBody handle
---@return number mass MainBody mass. Static bodies always return zero mass.
function GetBodyMass(handle) end
---Check if MainBody is dynamic. Note that something that was created static may become dynamic due to destruction.
---@param handle number MainBody handle
---@return boolean dynamic Return true if MainBody is dynamic
function IsBodyDynamic(handle) end
---Change the dynamic state of a MainBody. There is very limited use for this function. In most situations you should leave it up to the engine to decide. Use with caution.
---@param handle number MainBody handle
---@param dynamic boolean True for dynamic. False for static.
function SetBodyDynamic(handle, dynamic) end
---This can be used for animating bodies with preserved physical interaction, but in most cases you are better off with a motorized joint instead.
---@param handle number MainBody handle (should be a dynamic MainBody)
---@param velocity table Vector with linear velocity
function SetBodyVelocity(handle, velocity) end
---@param handle number MainBody handle (should be a dynamic MainBody)
---@return table velocity Linear velocity as vector
function GetBodyVelocity(handle) end
---Return the velocity on a MainBody taking both linear and angular velocity into account.
---@param handle number MainBody handle (should be a dynamic MainBody)
---@param pos table World space point as vector
---@return table velocity Linear velocity on MainBody at pos as vector
function GetBodyVelocityAtPos(handle, pos) end
---This can be used for animating bodies with preserved physical interaction, but in most cases you are better off with a motorized joint instead.
---@param handle number MainBody handle (should be a dynamic MainBody)
---@param angVel table Vector with angular velocity
function SetBodyAngularVelocity(handle, angVel) end
---@param handle number MainBody handle (should be a dynamic MainBody)
---@return table angVel Angular velocity as vector
function GetBodyAngularVelocity(handle) end
---Check if MainBody is MainBody is currently simulated. For performance reasons, bodies that don't move are taken out of the simulation. This function can be used to query the active state of a specific MainBody. Only dynamic bodies can be active.
---@param handle number MainBody handle
---@return boolean active Return true if MainBody is active
function IsBodyActive(handle) end
---This function makes it possible to manually activate and deactivate bodies to include or exclude in simulation. The engine normally handles this automatically, so use with care.
---@param handle number MainBody handle
---@param active boolean Set to tru if MainBody should be active (simulated)
function SetBodyActive(handle, active) end
---Apply impulse to dynamic MainBody at position (give MainBody a push).
---@param handle number MainBody handle (should be a dynamic MainBody)
---@param position table World space position as vector
---@param impulse table World space impulse as vector
function ApplyBodyImpulse(handle, position, impulse) end
---Return handles to all shapes owned by a MainBody
---@param handle number MainBody handle
---@return table list Indexed table of shape handles
function GetBodyShapes(handle) end
---@param MainBody number MainBody handle
---@return number handle Get parent vehicle for MainBody, or zero if not part of vehicle
function GetBodyVehicle(MainBody) end
---Return the world space, axis-aligned bounding box for a MainBody.
---@param handle number MainBody handle
---@return table max Vector representing the AABB upper bound
function GetBodyBounds(handle) end
---@param handle number MainBody handle
---@return table point Vector representing local center of mass in MainBody space
function GetBodyCenterOfMass(handle) end
---This will check if a MainBody is currently visible in the camera frustum and not occluded by other objects.
---@param handle number MainBody handle
---@param maxDist number Maximum visible distance
---@param rejectTransparent boolean [optional] See through transparent materials. Default false.
---@return boolean visible Return true if MainBody is visible
function IsBodyVisible(handle, maxDist, rejectTransparent) end
---Determine if any shape of a MainBody has been broken.
---@param handle number MainBody handle
---@return boolean broken Return true if MainBody is broken
function IsBodyBroken(handle) end
---Determine if a MainBody is in any way connected to a static object, either by being static itself or be being directly or indirectly jointed to something static.
---@param handle number MainBody handle
---@return boolean result Return true if MainBody is in any way connected to a static MainBody
function IsBodyJointedToStatic(handle) end
---Render next frame with an outline around specified MainBody. If no color is given, a white outline will be drawn.
---@param handle number MainBody handle
---@param r number [optional] Red
---@param g number [optional] Green
---@param b number [optional] Blue
---@param a number Alpha
function DrawBodyOutline(handle, r, g, b, a) end
---Flash the appearance of a MainBody when rendering this frame. This is used for valuables in the game.
---@param handle number MainBody handle
---@param amount number Amount
function DrawBodyHighlight(handle, amount) end
---This will return the closest point of a specific MainBody
---@param MainBody number MainBody handle
---@param origin table World space point
---@return number shape Handle to closest shape
function GetBodyClosestPoint(MainBody, origin) end
---This will tell the physics solver to constrain the velocity between two bodies. The physics solver will try to reach the desired goal, while not applying an impulse bigger than the min and max values. This function should only be used from the update callback.
---@param bodyA number First MainBody handle (zero for static)
---@param bodyB number Second MainBody handle (zero for static)
---@param point table World space point
---@param dir table World space direction
---@param relVel number Desired relative velocity along the provided direction
---@param min number [optional] Minimum impulse (default: -infinity)
---@param max number [optional] Maximum impulse (default: infinity)
function ConstrainVelocity(bodyA, bodyB, point, dir, relVel, min, max) end
---This will tell the physics solver to constrain the angular velocity between two bodies. The physics solver will try to reach the desired goal, while not applying an angular impulse bigger than the min and max values. This function should only be used from the update callback.
---@param bodyA number First MainBody handle (zero for static)
---@param bodyB number Second MainBody handle (zero for static)
---@param dir table World space direction
---@param relAngVel number Desired relative angular velocity along the provided direction
---@param min number [optional] Minimum angular impulse (default: -infinity)
---@param max number [optional] Maximum angular impulse (default: infinity)
function ConstrainAngularVelocity(bodyA, bodyB, dir, relAngVel, min, max) end
---This is a helper function that uses ConstrainVelocity to constrain a point on one MainBody to a point on another MainBody while not affecting the bodies more than the provided maximum relative velocity and maximum impulse. In other words: physically push on the bodies so that pointA and pointB are aligned in world space. This is useful for physically animating objects. This function should only be used from the update callback.
---@param bodyA number First MainBody handle (zero for static)
---@param bodyB number Second MainBody handle (zero for static)
---@param pointA table World space point for first MainBody
---@param pointB table World space point for second MainBody
---@param maxVel number [optional] Maximum relative velocity (default: infinite)
---@param maxImpulse number [optional] Maximum impulse (default: infinite)
function ConstrainPosition(bodyA, bodyB, pointA, pointB, maxVel, maxImpulse) end
---This is the angular counterpart to ConstrainPosition, a helper function that uses ConstrainAngularVelocity to constrain the orientation of one MainBody to the orientation on another MainBody while not affecting the bodies more than the provided maximum relative angular velocity and maximum angular impulse. In other words: physically rotate the bodies so that quatA and quatB are aligned in world space. This is useful for physically animating objects. This function should only be used from the update callback.
---@param bodyA number First MainBody handle (zero for static)
---@param bodyB number Second MainBody handle (zero for static)
---@param quatA table World space orientation for first MainBody
---@param quatB table World space orientation for second MainBody
---@param maxAngVel number [optional] Maximum relative angular velocity (default: infinite)
---@param maxAngImpulse number [optional] Maximum angular impulse (default: infinite)
function ConstrainOrientation(bodyA, bodyB, quatA, quatB, maxAngVel, maxAngImpulse) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return number handle Handle to first shape with specified tag or zero if not found
function FindShape(tag, global) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return table list Indexed table with handles to all shapes with specified tag
function FindShapes(tag, global) end
---@param handle number Shape handle
---@return table transform Return shape transform in MainBody space
function GetShapeLocalTransform(handle) end
---@param handle number Shape handle
---@param transform table Shape transform in MainBody space
function SetShapeLocalTransform(handle, transform) end
---This is a convenience function, transforming the shape out of MainBody space
---@param handle number Shape handle
---@return table transform Return shape transform in world space
function GetShapeWorldTransform(handle) end
---Get handle to the MainBody this shape is owned by. A shape is always owned by a MainBody, but can be transfered to a new MainBody during destruction.
---@param handle number Shape handle
---@return number handle MainBody handle
function GetShapeBody(handle) end
---@param shape number Shape handle
---@return table list Indexed table with joints connected to shape
function GetShapeJoints(shape) end
---@param shape number Shape handle
---@return table list Indexed table of lights owned by shape
function GetShapeLights(shape) end
---Return the world space, axis-aligned bounding box for a shape.
---@param handle number Shape handle
---@return table max Vector representing the AABB upper bound
function GetShapeBounds(handle) end
---Scale emissiveness for shape. If the shape has light sources attached, their intensity will be scaled by the same amount.
---@param handle number Shape handle
---@param scale number Scale factor for emissiveness
function SetShapeEmissiveScale(handle, scale) end
---Return material properties for a particular voxel
---@param handle number Shape handle
---@param pos table Position in world space
---@return number a Alpha
function GetShapeMaterialAtPosition(handle, pos) end
---Return material properties for a particular voxel in the voxel grid indexed by integer values. The first index is zero (not one, as opposed to a lot of lua related things)
---@param handle number Shape handle
---@param x number X integer coordinate
---@param y number Y integer coordinate
---@param z number Z integer coordinate
---@return number a Alpha
function GetShapeMaterialAtIndex(handle, x, y, z) end
---Return the size of a shape in voxels
---@param handle number Shape handle
---@return number scale The size of one voxel in meters (with default scale it is 0.1)
function GetShapeSize(handle) end
---Return the number of voxels in a shape, not including empty space
---@param handle number Shape handle
---@return number count Number of voxels in shape
function GetShapeVoxelCount(handle) end
---This will check if a shape is currently visible in the camera frustum and not occluded by other objects.
---@param handle number Shape handle
---@param maxDist number Maximum visible distance
---@param rejectTransparent boolean [optional] See through transparent materials. Default false.
---@return boolean visible Return true if shape is visible
function IsShapeVisible(handle, maxDist, rejectTransparent) end
---Determine if shape has been broken. Note that a shape can be transfered to another MainBody during destruction, but might still not be considered broken if all voxels are intact.
---@param handle number Shape handle
---@return boolean broken Return true if shape is broken
function IsShapeBroken(handle) end
---Render next frame with an outline around specified shape. If no color is given, a white outline will be drawn.
---@param handle number Shape handle
---@param r number [optional] Red
---@param g number [optional] Green
---@param b number [optional] Blue
---@param a number Alpha
function DrawShapeOutline(handle, r, g, b, a) end
---Flash the appearance of a shape when rendering this frame.
---@param handle number Shape handle
---@param amount number Amount
function DrawShapeHighlight(handle, amount) end
---This is used to filter out collisions with other shapes. Each shape can be given a layer bitmask (8 bits, 0-255) along with a mask (also 8 bits). The layer of one object must be in the mask of the other object and vice versa for the collision to be valid. The default layer for all objects is 1 and the default mask is 255 (collide with all layers).
---@param handle number Shape handle
---@param layer number Layer bits (0-255)
---@param mask number Mask bits (0-255)
function SetShapeCollisionFilter(handle, layer, mask) end
---This will return the closest point of a specific shape
---@param shape number Shape handle
---@param origin table World space point
---@return table normal World space normal at closest point
function GetShapeClosestPoint(shape, origin) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return number handle Handle to first location with specified tag or zero if not found
function FindLocation(tag, global) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return table list Indexed table with handles to all locations with specified tag
function FindLocations(tag, global) end
---@param handle number Location handle
---@return table transform Transform of the location
function GetLocationTransform(handle) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return number handle Handle to first joint with specified tag or zero if not found
function FindJoint(tag, global) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return table list Indexed table with handles to all joints with specified tag
function FindJoints(tag, global) end
---@param joint number Joint handle
---@return boolean broken True if joint is broken
function IsJointBroken(joint) end
---Joint type is one of the following: "ball", "hinge", "prismatic" or "rope". An empty string is returned if joint handle is invalid.
---@param joint number Joint handle
---@return string type Joint type
function GetJointType(joint) end
---A joint is always connected to two shapes. Use this function if you know one shape and want to find the other one.
---@param joint number Joint handle
---@param shape number Shape handle
---@return number other Other shape handle
function GetJointOtherShape(joint, shape) end
---Set joint motor target velocity. If joint is of type hinge, velocity is given in radians per second angular velocity. If joint type is prismatic joint velocity is given in meters per second. Calling this function will override and void any previous call to SetJointMotorTarget.
---@param joint number Joint handle
---@param velocity number Desired velocity
---@param strength number [optional] Desired strength. Default is infinite. Zero to disable.
function SetJointMotor(joint, velocity, strength) end
---If a joint has a motor target, it will try to maintain its relative movement. This is very useful for elevators or other animated, jointed mechanisms. If joint is of type hinge, target is an angle in degrees (-180 to 180) and velocity is given in radians per second. If joint type is prismatic, target is given in meters and velocity is given in meters per second. Setting a motor target will override any previous call to SetJointMotor.
---@param joint number Joint handle
---@param target number Desired movement target
---@param maxVel number [optional] Maximum velocity to reach target. Default is infinite.
---@param strength number [optional] Desired strength. Default is infinite. Zero to disable.
function SetJointMotorTarget(joint, target, maxVel, strength) end
---Return joint limits for hinge or prismatic joint. Returns angle or distance depending on joint type.
---@param joint number Joint handle
---@return number max Maximum joint limit (angle or distance)
function GetJointLimits(joint) end
---Return the current position or angle or the joint, measured in same way as joint limits.
---@param joint number Joint handle
---@return number movement Current joint position or angle
function GetJointMovement(joint) end
---@param MainBody number MainBody handle (must be dynamic)
---@return table bodies Handles to all dynamic bodies in the jointed structure. The input handle will also be included.
function GetJointedBodies(MainBody) end
---Detach joint from shape. If joint is not connected to shape, nothing happens.
---@param joint number Joint handle
---@param shape number Shape handle
function DetachJointFromShape(joint, shape) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return number handle Handle to first light with specified tag or zero if not found
function FindLight(tag, global) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return table list Indexed table with handles to all lights with specified tag
function FindLights(tag, global) end
---If light is owned by a shape, the emissive scale of that shape will be set to 0.0 when light is disabled and 1.0 when light is enabled.
---@param handle number Light handle
---@param enabled boolean Set to true if light should be enabled
function SetLightEnabled(handle, enabled) end
---This will only set the color tint of the light. Use SetLightIntensity for brightness. Setting the light color will not affect the emissive color of a parent shape.
---@param handle number Light handle
---@param r number Red value
---@param g number Green value
---@param b number Blue value
function SetLightColor(handle, r, g, b) end
---If the shape is owned by a shape you most likely want to use SetShapeEmissiveScale instead, which will affect both the emissiveness of the shape and the brightness of the light at the same time.
---@param handle number Light handle
---@param intensity number Desired intensity of the light
function SetLightIntensity(handle, intensity) end
---Lights that are owned by a dynamic shape are automatcially moved with that shape
---@param handle number Light handle
---@return table transform World space light transform
function GetLightTransform(handle) end
---@param handle number Light handle
---@return number handle Shape handle or zero if not attached to shape
function GetLightShape(handle) end
---@param handle number Light handle
---@return boolean active True if light is currently emitting light
function IsLightActive(handle) end
---@param handle number Light handle
---@param point table World space point as vector
---@return boolean affected Return true if point is in light cone and range
function IsPointAffectedByLight(handle, point) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return number handle Handle to first trigger with specified tag or zero if not found
function FindTrigger(tag, global) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return table list Indexed table with handles to all triggers with specified tag
function FindTriggers(tag, global) end
---@param handle number Trigger handle
---@return table transform Current trigger transform in world space
function GetTriggerTransform(handle) end
---@param handle number Trigger handle
---@param transform table Desired trigger transform in world space
function SetTriggerTransform(handle, transform) end
---Return the lower and upper points in world space of the trigger axis aligned bounding box
---@param handle number Trigger handle
---@return table max Upper point of trigger bounds in world space
function GetTriggerBounds(handle) end
---This function will only check the center point of the MainBody
---@param trigger number Trigger handle
---@param MainBody number MainBody handle
---@return boolean inside True if MainBody is in trigger volume
function IsBodyInTrigger(trigger, MainBody) end
---This function will only check origo of vehicle
---@param trigger number Trigger handle
---@param vehicle number Vehicle handle
---@return boolean inside True if vehicle is in trigger volume
function IsVehicleInTrigger(trigger, vehicle) end
---This function will only check the center point of the shape
---@param trigger number Trigger handle
---@param shape number Shape handle
---@return boolean inside True if shape is in trigger volume
function IsShapeInTrigger(trigger, shape) end
---@param trigger number Trigger handle
---@param point table Word space point as vector
---@return boolean inside True if point is in trigger volume
function IsPointInTrigger(trigger, point) end
---This function will check if trigger is empty. If trigger contains any part of a MainBody it will return false and the highest point as second return value.
---@param handle number Trigger handle
---@param demolision boolean [optional] If true, small debris and vehicles are ignored
---@return table maxpoint World space point of highest point (largest Y coordinate) if not empty
function IsTriggerEmpty(handle, demolision) end
---Get distance to the surface of trigger volume. Will return negative distance if inside.
---@param trigger number Trigger handle
---@param point table Word space point as vector
---@return number distance Positive if point is outside, negative if inside
function GetTriggerDistance(trigger, point) end
---Return closest point in trigger volume. Will return the input point itself if inside trigger or closest point on surface of trigger if outside.
---@param trigger number Trigger handle
---@param point table Word space point as vector
---@return table closest Closest point in trigger as vector
function GetTriggerClosestPoint(trigger, point) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return number handle Handle to first screen with specified tag or zero if not found
function FindScreen(tag, global) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return table list Indexed table with handles to all screens with specified tag
function FindScreens(tag, global) end
---Enable or disable screen
---@param screen number Screen handle
---@param enabled boolean True if screen should be enabled
function SetScreenEnabled(screen, enabled) end
---@param screen number Screen handle
---@return boolean enabled True if screen is enabled
function IsScreenEnabled(screen) end
---Return handle to the parent shape of a screen
---@param screen number Screen handle
---@return number shape Shape handle or zero if none
function GetScreenShape(screen) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return number handle Handle to first vehicle with specified tag or zero if not found
function FindVehicle(tag, global) end
---@param tag string Tag name
---@param global boolean [optional] Search in entire scene
---@return table list Indexed table with handles to all vehicles with specified tag
function FindVehicles(tag, global) end
---@param vehicle number Vehicle handle
---@return table transform Transform of vehicle
function GetVehicleTransform(vehicle) end
---@param vehicle number Vehicle handle
---@return number MainBody Main MainBody of vehicle
function GetVehicleBody(vehicle) end
---@param vehicle number Vehicle handle
---@return number health Vehicle health (zero to one)
function GetVehicleHealth(vehicle) end
---@param vehicle number Vehicle handle
---@return table pos Driver position as vector in vehicle space
function GetVehicleDriverPos(vehicle) end
---This function applies input to vehicles, allowing for autonomous driving. The vehicle will be turned on automatically and turned off when no longer called. Call this from the tick function, not update.
---@param vehicle number Vehicle handle
---@param drive number Reverse/forward control -1 to 1
---@param steering number Left/Right control -1 to 1
---@param handbrake boolean Handbrake control
function DriveVehicle(vehicle, drive, steering, handbrake) end
---Return center point of player. This function is deprecated. Use GetPlayerTransform instead.
---@return table position Player center position
function GetPlayerPos() end
---The player transform is located at the bottom of the player. The player transform considers heading (looking Left and Right). Forward is along negative Z axis. Player pitch (looking up and down) does not affect player transform unless includePitch is set to true. If you want the transform of the eye, use GetPlayerCameraTransform() instead.
---@param includePitch boolean Include the player pitch (look up/down) in transform
---@return table transform Current player transform
function GetPlayerTransform(includePitch) end
---Instantly teleport the player to desired transform. Unless includePitch is set to true, up/down look angle will be set to zero during this process. Player velocity will be reset to zero.
---@param transform table Desired player transform
---@param includePitch boolean Set player pitch (look up/down) as well
function SetPlayerTransform(transform, includePitch) end
---Make the ground act as a conveyor belt, pushing the player even if ground shape is static.
---@param vel table Desired ground velocity
function SetPlayerGroundVelocity(vel) end
---The player camera transform is usually the same as what you get from GetCameraTransform, but if you have set a camera transform manually with SetCameraTransform, you can retrieve the standard player camera transform with this function.
---@return table transform Current player camera transform
function GetPlayerCameraTransform() end
---Call this function during init to alter the player spawn transform.
---@param transform table Desired player spawn transform
function SetPlayerSpawnTransform(transform) end
---@return table velocity Player velocity in world space as vector
function GetPlayerVelocity() end
---Drive specified vehicle.
---@param vehicle number Handle to vehicle or zero to not drive.
function SetPlayerVehicle(vehicle) end
---@param velocity table Player velocity in world space as vector
function SetPlayerVelocity(velocity) end
---@return number handle Current vehicle handle, or zero if not in vehicle
function GetPlayerVehicle() end
---@return number handle Handle to grabbed shape or zero if not grabbing.
function GetPlayerGrabShape() end
---@return number handle Handle to grabbed MainBody or zero if not grabbing.
function GetPlayerGrabBody() end
---Release what the player is currently holding
function ReleasePlayerGrab() end
---@return number handle Handle to picked shape or zero if nothing is picked
function GetPlayerPickShape() end
---@return number handle Handle to picked MainBody or zero if nothing is picked
function GetPlayerPickBody() end
---Interactable shapes has to be tagged with "interact". The engine determines which interactable shape is currently interactable.
---@return number handle Handle to interactable shape or zero
function GetPlayerInteractShape() end
---Interactable shapes has to be tagged with "interact". The engine determines which interactable MainBody is currently interactable.
---@return number handle Handle to interactable MainBody or zero
function GetPlayerInteractBody() end
---Set the screen the player should interact with. For the screen to feature a mouse pointer and receieve input, the screen also needs to have interactive property.
---@param handle number Handle to screen or zero for no screen
function SetPlayerScreen(handle) end
---@return number handle Handle to interacted screen or zero if none
function GetPlayerScreen() end
---@param health number Set player health (between zero and one)
function SetPlayerHealth(health) end
---@return number health Current player health
function GetPlayerHealth() end
---Respawn player at spawn position without modifying the scene
function RespawnPlayer() end
---Register a custom tool that will show up in the player inventory and can be selected with scroll wheel. Do this only once per tool. You also need to enable the tool in the registry before it can be used.
---@param id string Tool unique identifier
---@param name string Tool name to show in hud
---@param file string Path to vox file
---@param group number [optional] Tool group for this tool (1-6) Default is 6.
function RegisterTool(id, name, file, group) end
---Return MainBody handle of the visible tool. You can use this to retrieve tool shapes and animate them, change emissiveness, etc. Do not attempt to set the tool MainBody transform, since it is controlled by the engine. Use SetToolTranform for that.
---@return number handle Handle to currently visible tool MainBody or zero if none
function GetToolBody() end
---Apply an additional transform on the visible tool MainBody. This can be used to create tool animations. You need to set this every frame from the tick function. The optional sway parameter control the amount of tool swaying when walking. Set to zero to disable completely.
---@param transform table Tool MainBody transform
---@param sway number Tool sway amount. Default is 1.0.
function SetToolTransform(transform, sway) end
---@param path string Path to ogg sound file
---@param nominalDistance number [optional] The distance in meters this sound is recorded at. Affects attenuation, default is 10.0
---@return number handle Sound handle
function LoadSound(path, nominalDistance) end
---@param path string Path to ogg sound file
---@param nominalDistance number [optional] The distance in meters this sound is recorded at. Affects attenuation, default is 10.0
---@return number handle Loop handle
function LoadLoop(path, nominalDistance) end
---@param handle number Sound handle
---@param pos table [optional] World position as vector. Default is player position.
---@param volume number [optional] Playback volume. Default is 1.0
function PlaySound(handle, pos, volume) end
---Call this function continuously to play loop
---@param handle number Loop handle
---@param pos table [optional] World position as vector. Default is player position.
---@param volume number [optional] Playback volume. Default is 1.0
function PlayLoop(handle, pos, volume) end
---@param path string Music path
function PlayMusic(path) end
function StopMusic() end
---@param path string Path to sprite. Must be PNG or JPG format.
---@return number handle Sprite handle
function LoadSprite(path) end
---Draw sprite in world at next frame. Call this function from the tick callback.
---@param handle number Sprite handle
---@param transform table Transform
---@param width number Width in meters
---@param height number Height in meters
---@param r number [optional] Red color. Default 1.0.
---@param g number [optional] Green color. Default 1.0.
---@param b number [optional] Blue color. Default 1.0.
---@param a number [optional] Alpha. Default 1.0.
---@param depthTest boolean [optional] Depth test enabled. Default false.
---@param additive boolean [optional] Additive blending enabled. Default false.
function DrawSprite(handle, transform, width, height, r, g, b, a, depthTest, additive) end
---Set required layers for next query. Available layers are:
---@param layers string Space separate list of layers
function QueryRequire(layers) end
---Exclude vehicle from the next query
---@param vehicle number Vehicle handle
function QueryRejectVehicle(vehicle) end
---Exclude MainBody from the next query
---@param MainBody number MainBody handle
function QueryRejectBody(MainBody) end
---Exclude shape from the next query
---@param shape number Shape handle
function QueryRejectShape(shape) end
---This will perform a raycast or spherecast (if radius is more than zero) query. If you want to set up a filter for the query you need to do so before every call to this function.
---@param origin table Raycast origin as world space vector
---@param direction table Unit length raycast direction as world space vector
---@param maxDist number Raycast maximum distance. Keep this as low as possible for good performance.
---@param radius number [optional] Raycast thickness. Default zero.
---@param rejectTransparent boolean [optional] Raycast through transparent materials. Default false.
---@return number shape Handle to hit shape
function QueryRaycast(origin, direction, maxDist, radius, rejectTransparent) end
---This will query the closest point to all shapes in the world. If you want to set up a filter for the query you need to do so before every call to this function.
---@param origin table World space point
---@param maxDist number Maximum distance. Keep this as low as possible for good performance.
---@return number shape Handle to closest shape
function QueryClosestPoint(origin, maxDist) end
---Return all shapes within the provided world space, axis-aligned bounding box
---@param min table Aabb minimum point
---@param max table Aabb maximum point
---@return table list Indexed table with handles to all shapes in the aabb
function QueryAabbShapes(min, max) end
---Return all bodies within the provided world space, axis-aligned bounding box
---@param min table Aabb minimum point
---@param max table Aabb maximum point
---@return table list Indexed table with handles to all bodies in the aabb
function QueryAabbBodies(min, max) end
---Initiate path planning query. The result will run asynchronously as long as GetPathState retuns "busy". An ongoing path query can be aborted with AbortPath. The path planning query will use the currently set up query filter, just like the other query functions.
---@param start table World space start point
---@param _end table World space target point
---@param maxDist number [optional] Maximum path length before giving up. Default is infinite.
---@param targetRadius number [optional] Maximum allowed distance to target in meters. Default is 2.0
function QueryPath(start, _end, maxDist, targetRadius) end
---Abort current path query, regardless of what state it is currently in. This is a way to save computing resources if the result of the current query is no longer of interest.
function AbortPath() end
---Return the current state of the last path planning query.
---@return string state Current path planning state
function GetPathState() end
---Return the path length of the most recently computed path query. Note that the result can often be retrieved even if the path query failed. If the target point couldn't be reached, the path endpoint will be the point closest to the target.
---@return number length Length of last path planning result (in meters)
function GetPathLength() end
---Return a point along the path for the most recently computed path query. Note that the result can often be retrieved even if the path query failed. If the target point couldn't be reached, the path endpoint will be the point closest to the target.
---@param dist number The distance along path. Should be between zero and result from GetPathLength()
---@return table point The path point dist meters along the path
function GetPathPoint(dist) end
---@return table position World position of loudest sound played last frame
function GetLastSound() end
---@param point table World point as vector
---@return number depth Depth of point into water, or zero if not in water
function IsPointInWater(point) end
---Get the wind velocity at provided point. The wind will be determined by wind property of the environment, but it varies with position procedurally.
---@param point table World point as vector
---@return table vel Wind at provided position
function GetWindVelocity(point) end
---Reset to default particle state, which is a plain, white particle of radius 0.5. Collision is enabled and it alpha animates from 1 to 0.
function ParticleReset() end
---Set type of particle
---@param type string Type of particle. Can be "smoke" or "plain".
function ParticleType(type) end
---@param type number [int] Tile in the particle texture atlas (0-15)
function ParticleTile(type) end
---Set particle color to either constant (three arguments) or linear interpolation (six arguments)
---@param r0 number [float] Red value
---@param g0 number [float] Green value
---@param b0 number [float] Blue value
---@param r1 number [optional] [float] Red value at end
---@param g1 number [optional] [float] Green value at end
---@param b1 number [optional] [float] Blue value at end
function ParticleColor(r0, g0, b0, r1, g1, b1) end
---Set the particle radius. Max radius for smoke particles is 1.0.
---@param r0 number [float] Radius
---@param r1 number [optional] [float] End radius
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleRadius(r0, r1, interpolation, fadein, fadeout) end
---Set the particle alpha (opacity).
---@param a0 number [float] Alpha (0.0 - 1.0)
---@param a1 number [optional] [float] End alpha (0.0 - 1.0)
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleAlpha(a0, a1, interpolation, fadein, fadeout) end
---Set particle gravity. It will be applied along the world Y axis. A negative value will move the particle downwards.
---@param g0 number [float] Gravity
---@param g1 number [optional] [float] End gravity
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleGravity(g0, g1, interpolation, fadein, fadeout) end
---Particle drag will slow down fast moving particles. It's implemented slightly different for smoke and plain particles. Drag must be positive, and usually look good between zero and one.
---@param d0 number [float] Drag
---@param d1 number [optional] [float] End drag
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleDrag(d0, d1, interpolation, fadein, fadeout) end
---Draw particle as emissive (glow in the dark). This is useful for fire and embers.
---@param d0 number [float] Emissive
---@param d1 number [optional] [float] End emissive
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleEmissive(d0, d1, interpolation, fadein, fadeout) end
---Makes the particle rotate. Positive values is counter-clockwise rotation.
---@param r0 number [float] Rotation speed in radians per second.
---@param r1 number [optional] [float] End rotation speed in radians per second.
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleRotation(r0, r1, interpolation, fadein, fadeout) end
---Stretch particle along with velocity. 0.0 means no stretching. 1.0 stretches with the particle motion over one frame. Larger values stretches the particle even more.
---@param s0 number [float] Stretch
---@param s1 number [optional] [float] End stretch
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleStretch(s0, s1, interpolation, fadein, fadeout) end
---Make particle stick when in contact with objects. This can be used for friction.
---@param s0 number [float] Sticky (0.0 - 1.0)
---@param s1 number [optional] [float] End sticky (0.0 - 1.0)
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleSticky(s0, s1, interpolation, fadein, fadeout) end
---Control particle collisions. A value of zero means that collisions are ignored. One means full collision. It is sometimes useful to animate this value from zero to one in order to not collide with objects around the emitter.
---@param c0 number [float] Collide (0.0 - 1.0)
---@param c1 number [optional] [float] End collide (0.0 - 1.0)
---@param interpolation string [optional] Interpolation method: linear, smooth, easein, easeout or constant. Default is linear.
---@param fadein number [optional] [float] Fade in between t=0 and t=fadein. Default is zero.
---@param fadeout number [optional] [float] Fade out between t=fadeout and t=1. Default is one.
function ParticleCollide(c0, c1, interpolation, fadein, fadeout) end
---Set particle bitmask. The value 256 means fire extinguishing particles and is currently the only flag in use. There might be support for custom flags and queries in the future.
---@param bitmask number Particle flags (bitmask 0-65535)
function ParticleFlags(bitmask) end
---Spawn particle using the previously set up particle state. You can call this multiple times using the same particle state, but with different position, velocity and lifetime. You can also modify individual properties in the particle state in between calls to to this function.
---@param pos table World space point as vector
---@param velocity table World space velocity as vector
---@param lifetime number Particle lifetime in seconds
function SpawnParticle(pos, velocity, lifetime) end
---Shoot bullet or rocket (used for chopper)
---@param origin table Origin in world space as vector
---@param direction table Unit length direction as world space vector
---@param type number [optional] 0 is regular bullet (default) and 1 is rocket
function Shoot(origin, direction, type) end
---Make a hole in the environment. Radius is given in meters. Soft materials: glass, foliage, dirt, wood, plaster and plastic. Medium materials: concrete, brick and weak metal. Hard materials: hard metal and hard masonry.
---@param position table Hole center point
---@param r0 number Hole radius for soft materials
---@param r1 number [optional] Hole radius for medium materials. May not be bigger than r0. Default zero.
---@param r2 number [optional] Hole radius for hard materials. May not be bigger than r1. Default zero.
---@param silent boolean [optional] Make hole without playing any break sounds.
function MakeHole(position, r0, r1, r2, silent) end
---@param pos table Position in world space as vector
---@param size number Explosion size from 0.5 to 4.0
function Explosion(pos, size) end
---@param pos table Position in world space as vector
function SpawnFire(pos) end
---@return number count Number of active fires in level
function GetFireCount() end
---@param origin table World space position as vector
---@param maxDist number Maximum search distance
---@return table pos Position of closest fire
function QueryClosestFire(origin, maxDist) end
---@param min table Aabb minimum point
---@param max table Aabb maximum point
---@return number count Number of active fires in bounding box
function QueryAabbFireCount(min, max) end
---@param min table Aabb minimum point
---@param max table Aabb maximum point
---@return number count Number of fires removed
function RemoveAabbFires(min, max) end
---@return table transform Current camera transform
function GetCameraTransform() end
---Override current camera transform for this frame. Call continuously to keep overriding.
---@param transform table Desired camera transform
---@param fov number [optional] Optional horizontal field of view in degrees (default: 90)
function SetCameraTransform(transform, fov) end
---Override field of view for the next frame for all camera modes, except when explicitly set in SetCameraTransform
---@param degrees number Horizontal field of view in degrees (10-170)
function SetCameraFov(degrees) end
---Override depth of field for the next frame for all camera modes. Depth of field will be used even if turned off in options.
---@param distance number Depth of field distance
---@param amount number [optional] Optional amount of blur (default 1.0)
function SetCameraDof(distance, amount) end
---Add a temporary point light to the world for this frame. Call continuously for a steady light.
---@param pos table World space light position
---@param r number Red
---@param g number Green
---@param b number Blue
---@param intensity number [optional] Intensity. Default is 1.0.
function PointLight(pos, r, g, b, intensity) end
---Experimental. Scale time in order to make a slow-motion effect. Audio will also be affected. Note that this will affect physics behavior and is not intended for gameplay purposes. Calling this function will slow down time for the next frame only. Call every frame from tick function to get steady slow-motion.
---@param scale number Time scale 0.1 to 1.0
function SetTimeScale(scale) end
---Reset the environment properties to default. This is often useful before setting up a custom environment.
function SetEnvironmentDefault() end
---This function is used for manipulating the environment properties. The available properties are exactly the same as in the editor.
---@param name string Property name
---@param value0 number [varying] Property value (type depends on property)
---@param value1 number [optional] [varying] Extra property value (only some properties)
---@param value2 number [optional] [varying] Extra property value (only some properties)
---@param value3 number [optional] [varying] Extra property value (only some properties)
function SetEnvironmentProperty(name, value0, value1, value2, value3) end
---This function is used for querying the current environment properties. The available properties are exactly the same as in the editor.
---@param name string Property name
---@return number value4 [varying] Property value (only some properties)
function GetEnvironmentProperty(name) end
---Reset the post processing properties to default.
function SetPostProcessingDefault() end
---This function is used for manipulating the post processing properties. The available properties are exactly the same as in the editor.
---@param name string Property name
---@param value0 number Property value
---@param value1 number [optional] Extra property value (only some properties)
---@param value2 number [optional] Extra property value (only some properties)
function SetPostProcessingProperty(name, value0, value1, value2) end
---This function is used for querying the current post processing properties. The available properties are exactly the same as in the editor.
---@param name string Property name
---@return number value2 Property value (only some properties)
function GetPostProcessingProperty(name) end
---Draw a 3D line. In contrast to DebugLine, it will not show behind objects. Default color is white.
---@param p0 table World space point as vector
---@param p1 table World space point as vector
---@param r number [optional] Red
---@param g number [optional] Green
---@param b number [optional] Blue
---@param a number [optional] Alpha
function DrawLine(p0, p1, r, g, b, a) end
---Draw a 3D debug overlay line in the world. Default color is white.
---@param p0 table World space point as vector
---@param p1 table World space point as vector
---@param r number [optional] Red
---@param g number [optional] Green
---@param b number [optional] Blue
---@param a number [optional] Alpha
function DebugLine(p0, p1, r, g, b, a) end
---Draw a debug cross in the world to highlight a location. Default color is white.
---@param p0 table World space point as vector
---@param r number [optional] Red
---@param g number [optional] Green
---@param b number [optional] Blue
---@param a number [optional] Alpha
function DebugCross(p0, r, g, b, a) end
---Show a named valued on screen for debug purposes. Up to 32 values can be shown simultaneously. Values updated the current frame are drawn opaque. Old values are drawn transparent in white.
---@param name string Name
---@param value string Value
function DebugWatch(name, value) end
---Display message on screen. The last 20 lines are displayed.
---@param message string Message to display
function DebugPrint(message) end
---Calling this function will disable game input, bring up the mouse pointer and allow Ui interaction with the calling script without pausing the game. This can be useful to make interactive user interfaces from scripts while the game is running. Call this continuously every frame as long as Ui interaction is desired.
function UiMakeInteractive() end
---Push state onto stack. This is used in combination with UiPop to remember a state and restore to that state later.
function UiPush() end
---Pop state from stack and make it the current one. This is used in combination with UiPush to remember a previous state and go back to it later.
function UiPop() end
---@return number width Width of draw context
function UiWidth() end
---@return number height Height of draw context
function UiHeight() end
---@return number center Half width of draw context
function UiCenter() end
---@return number middle Half height of draw context
function UiMiddle() end
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a number [optional] Alpha channel. Default 1.0
function UiColor(r, g, b, a) end
---Color filter, multiplied to all future colors in this scope
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a number [optional] Alpha channel. Default 1.0
function UiColorFilter(r, g, b, a) end
---Translate cursor
---@param x number X component
---@param y number Y component
function UiTranslate(x, y) end
---Rotate cursor
---@param angle number Angle in degrees, counter clockwise
function UiRotate(angle) end
---Scale cursor either uniformly (one argument) or non-uniformly (two arguments)
---@param x number X component
---@param y number [optional] Y component. Default value is x.
function UiScale(x, y) end
---Set up new bounds. Calls to UiWidth, UiHeight, UiCenter and UiMiddle will operate in the context of the window size. If clip is set to true, contents of window will be clipped to bounds (only works properly for non-rotated windows).
---@param width number Window width
---@param height number Window height
---@param clip boolean [optional] Clip content outside window. Default is false.
function UiWindow(width, height, clip) end
---Return a safe drawing area that will always be visible regardless of display aspect ratio. The safe drawing area will always be 1920 by 1080 in size. This is useful for setting up a fixed size UI.
---@return number y1 Bottom
function UiSafeMargins() end
---The alignment determines how content is aligned with respect to the cursor.
---@param alignment string Alignment keywords
function UiAlign(alignment) end
---Disable input for everything, except what's between UiModalBegin and UiModalEnd (or if modal state is popped)
function UiModalBegin() end
---Disable input for everything, except what's between UiModalBegin and UiModalEnd Calling this function is optional. Modality is part of the current state and will be lost if modal state is popped.
function UiModalEnd() end
---Disable input
function UiDisableInput() end
---Enable input that has been previously disabled
function UiEnableInput() end
---This function will check current state receives input. This is the case if input is not explicitly disabled with (with UiDisableInput) and no other state is currently modal (with UiModalBegin). Input functions and UI elements already do this check internally, but it can sometimes be useful to read the input state manually to trigger things in the UI.
---@return boolean receives True if current context receives input
function UiReceivesInput() end
---Get mouse pointer position relative to the cursor
---@return number y Y coordinate
function UiGetMousePos() end
---Check if mouse pointer is within rectangle. Note that this function respects alignment.
---@param w number Width
---@param h number Height
---@return boolean inside True if mouse pointer is within rectangle
function UiIsMouseInRect(w, h) end
---Convert world space position to user interface X and Y coordinate relative to the cursor. The distance is in meters and positive if in front of camera, negative otherwise.
---@param point table 3D world position as vector
---@return number distance Distance to point
function UiWorldToPixel(point) end
---Convert X and Y UI coordinate to a world direction, as seen from current camera. This can be used to raycast into the scene from the mouse pointer position.
---@param x number X coordinate
---@param y number Y coordinate
---@return table direction 3D world direction as vector
function UiPixelToWorld(x, y) end
---Perform a gaussian blur on current screen content
---@param amount number Blur amount (0.0 to 1.0)
function UiBlur(amount) end
---@param path string Path to TTF font file
---@param size number Font size (10 to 100)
function UiFont(path, size) end
---@return number size Font size
function UiFontHeight() end
---@param text string Print text at cursor location
---@param move boolean [optional] Automatically move cursor vertically. Default false.
---@return number h Height of text
function UiText(text, move) end
---@param text string A text string
---@return number h Height of text
function UiGetTextSize(text) end
---@param width number Maximum width of text
function UiWordWrap(width) end
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a number Alpha channel
---@param thickness number [optional] Outline thickness. Default is 0.1
function UiTextOutline(r, g, b, a, thickness) end
---@param r number Red channel
---@param g number Green channel
---@param b number Blue channel
---@param a number Alpha channel
---@param distance number [optional] Shadow distance. Default is 1.0
---@param blur number [optional] Shadow blur. Default is 0.5
function UiTextShadow(r, g, b, a, distance, blur) end
---Draw solid rectangle at cursor position
---@param w number Width
---@param h number Height
function UiRect(w, h) end
---Draw image at cursor position
---@param path string Path to image (PNG or JPG format)
---@return number h Image height
function UiImage(path) end
---Get image size
---@param path string Path to image (PNG or JPG format)
---@return number h Image height
function UiGetImageSize(path) end
---Draw 9-slice image at cursor position. Width should be at least 2*borderWidth. Height should be at least 2*borderHeight.
---@param path string Path to image (PNG or JPG format)
---@param width number Width
---@param height number Height
---@param borderWidth number Border width
---@param borderHeight number Border height
function UiImageBox(path, width, height, borderWidth, borderHeight) end
---UI sounds are not affected by acoustics simulation. Use LoadSound / PlaySound for that.
---@param path string Path to sound file (OGG format)
---@param volume number [optional] Playback volume. Default 1.0
---@param pitch number [optional] Playback pitch. Default 1.0
---@param pan number [optional] Playback stereo panning (-1.0 to 1.0). Default 0.0.
function UiSound(path, volume, pitch, pan) end
---Call this continuously to keep playing loop. UI sounds are not affected by acoustics simulation. Use LoadLoop / PlayLoop for that.
---@param path string Path to looping sound file (OGG format)
---@param volume number [optional] Playback volume. Default 1.0
function UiSoundLoop(path, volume) end
---Mute game audio and optionally music for the next frame. Call continuously to stay muted.
---@param amount number Mute by this amount (0.0 to 1.0)
---@param music boolean [optional] Mute music as well
function UiMute(amount, music) end
---Set up 9-slice image to be used as background for buttons.
---@param path string Path to image (PNG or JPG format)
---@param borderWidth number Border width
---@param borderHeight number Border height
---@param r number [optional] Red multiply. Default 1.0
---@param g number [optional] Green multiply. Default 1.0
---@param b number [optional] Blue multiply. Default 1.0
---@param a number [optional] Alpha channel. Default 1.0
function UiButtonImageBox(path, borderWidth, borderHeight, r, g, b, a) end
---Button color filter when hovering mouse pointer.
---@param r number Red multiply
---@param g number Green multiply
---@param b number Blue multiply
---@param a number [optional] Alpha channel. Default 1.0
function UiButtonHoverColor(r, g, b, a) end
---Button color filter when pressing down.
---@param r number Red multiply
---@param g number Green multiply
---@param b number Blue multiply
---@param a number [optional] Alpha channel. Default 1.0
function UiButtonPressColor(r, g, b, a) end
---The button offset when being pressed
---@param dist number Press distance
function UiButtonPressDist(dist) end
---@param text string Text on button
---@param w number [optional] Button width
---@param h number [optional] Button height
---@return boolean pressed True if user clicked button
function UiTextButton(text, w, h) end
---@param path number Image path (PNG or JPG file)
---@param w number [optional] Button width
---@param h number [optional] Button height
---@return boolean pressed True if user clicked button
function UiImageButton(path, w, h) end
---@param w number Button width
---@param h number Button height
---@return boolean pressed True if user clicked button
function UiBlankButton(w, h) end
---@param path number Image path (PNG or JPG file)
---@param axis string Drag axis, must be "x" or "y"
---@param current number Current value
---@param min number Minimum value
---@param max number Maximum value
---@return boolean done True if user is finished changing (released slider)
function UiSlider(path, axis, current, min, max) end
---@return number handle Handle to the screen running this script or zero if none.
function UiGetScreen() end
