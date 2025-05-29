#include "src/game/envfx_snow.h"

const GeoLayout squidhat_b[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, squid_hat_lunette_mesh),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
