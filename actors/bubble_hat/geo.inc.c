const GeoLayout bubblehat_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, bubble_hat_bhat_mesh),
		//GEO_DISPLAY_LIST(LAYER_OPAQUE, cutter_hat_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
