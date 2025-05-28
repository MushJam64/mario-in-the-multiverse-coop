#include "src/game/envfx_snow.h"

const GeoLayout bubblehat_handg[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, bubblehat_hand_hand_mesh),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
