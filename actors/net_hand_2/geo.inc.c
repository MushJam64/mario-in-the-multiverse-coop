const GeoLayout net_hand2_geo[] = {
	GEO_NODE_START(),
	GEO_OPEN_NODE(),
		GEO_DISPLAY_LIST(LAYER_OPAQUE, net_hand_2_hand_mesh),
		//GEO_DISPLAY_LIST(LAYER_OPAQUE, cutter_hat_material_revert_render_settings),
	GEO_CLOSE_NODE(),
	GEO_END(),
};
