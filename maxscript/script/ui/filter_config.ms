rollout outliner_filter_config "Filters"
(
	function close = 
	(
		if (outliner_status != undefined) do outliner_status.filterConfigOpen = false;
		destroyDialog outliner_filter_config;
	)
	
	local treeFilter;
	local buttons;
	local filter_refs;
	local hideByCat_refs;
	
	local btn_x = 3;
	local btn_y = 3;
	local btn_w = 25;
	local btn_h = 25;
	
	checkButton filter_hi tooltip:"Hidden" width:btn_w height:btn_h pos:[btn_x, btn_y];
	checkButton filter_fr tooltip:"Frozen" width:btn_w height:btn_h pos:[btn_x, btn_y + btn_h];
	
	local btn_x2 = btn_x + btn_w + 8;
	checkButton filter_go tooltip:"Geometry" width:btn_w height:btn_h pos:[btn_x2, btn_y];
	checkButton filter_sh tooltip:"Shapes" width:btn_w height:btn_h pos:[btn_x2 + btn_w, btn_y];
	checkButton filter_li tooltip:"Lights" width:btn_w height:btn_h pos:[btn_x2 + btn_w * 2, btn_y];
	checkButton filter_ca tooltip:"Cameras" width:btn_w height:btn_h pos:[btn_x2 + btn_w * 3, btn_y];
	checkButton filter_he tooltip:"Helpers" width:btn_w height:btn_h pos:[btn_x2 + btn_w * 4, btn_y];
	
	local btn_y2 = btn_y + btn_h;
	checkButton filter_sw tooltip:"Spacewarps" width:btn_w height:btn_h pos:[btn_x2, btn_y2];
	checkButton filter_bo tooltip:"Bones" width:btn_w height:btn_h pos:[btn_x2 + btn_w, btn_y2];
	checkButton filter_pa tooltip:"Particle Systems" width:btn_w height:btn_h pos:[btn_x2 + btn_w * 2, btn_y2];
	checkButton filter_xr tooltip:"XRefs" width:btn_w height:btn_h pos:[btn_x2 + btn_w * 3, btn_y2];
	
	
	
	--Check whether outliner is still open. Just a precaution, this window should never be open while the outliner isn't.
	function checkOutlinerStatus =
	(
		if ((outliner_status == undefined) OR (outliner_status.windowOpen == false)) then
		(
			close();
			false;
		)
		else
			true;
	)
	
	
	
	function setButtonStates =
	(
		for i = 1 to buttons.count do
		(
			buttons[i].checked = *(filter_refs[i]);
		)
	)
	
	
	function setFilterRange begin end enabled =
	(
		if (checkOutlinerStatus()) do
		(
			for i = begin to end do
			(
				buttons[i].checked = enabled;
				(outliner.prefs.getValue #Tree #objFilter)[i] = enabled;
				if (i <= filter_refs.count) do *filter_refs[i] = enabled;
				if ((outliner.prefs.getValue #Tree #objFilterAffectsVpt) AND (outliner.prefs.getValue #Tree #objFilterEnabled) AND i <= hideByCat_refs.count) do *hideByCat_refs[i] = not enabled;
			)
			outliner.prefs.savePreferences();
			
			if (outliner.prefs.getValue #Tree #objFilterEnabled) do outliner.tree.FillTree();
		)
	)
	
	
	function setFilter prop enabled =
	(
		if (keyboard.controlPressed) then
		(
			if (prop < 10) then
				setFilterRange 1 9 (not enabled);
			else
				setFilterRange 10 11 (not enabled);
				
			setFilterRange prop prop enabled;
		)
		else
			setFilterRange prop prop enabled;
	)
	
	-- Filter category button events.
	on filter_go changed checked do setFilter 1 checked;
	on filter_sh changed checked do setFilter 2 checked;
	on filter_li changed checked do setFilter 3 checked;
	on filter_ca changed checked do setFilter 4 checked;
	on filter_he changed checked do setFilter 5 checked;
	on filter_sw changed checked do setFilter 6 checked;
	on filter_bo changed checked do setFilter 7 checked;
	on filter_pa changed checked do setFilter 8 checked;
	on filter_xr changed checked do setFilter 9 checked;
	on filter_hi changed checked do setFilter 10 checked;
	on filter_fr changed checked do setFilter 11 checked;
	
	on filter_go rightclick do setFilterRange 1 9 (not filter_go.checked);
	on filter_sh rightclick do setFilterRange 1 9 (not filter_sh.checked);
	on filter_li rightclick do setFilterRange 1 9 (not filter_li.checked);
	on filter_ca rightclick do setFilterRange 1 9 (not filter_ca.checked);
	on filter_he rightclick do setFilterRange 1 9 (not filter_he.checked);
	on filter_sw rightclick do setFilterRange 1 9 (not filter_sw.checked);
	on filter_bo rightclick do setFilterRange 1 9 (not filter_bo.checked);
	on filter_pa rightclick do setFilterRange 1 9 (not filter_pa.checked);
	on filter_xr rightclick do setFilterRange 1 9 (not filter_xr.checked);
	on filter_hi rightclick do setFilterRange 10 11 (not filter_hi.checked);
	on filter_fr rightclick do setFilterRange 10 11 (not filter_fr.checked);
	
	
	
	function setButtonImages =
	(
		local iconSet = outliner.prefs.getValue #Visual #iconset;
		local imageFile = outliner.icondir;
		local alphaImageFile = outliner.icondir;
		if (iconSet == "Max") then
		(
			imageFile += "filter_icons_max";
			alphaImageFile += "filter_icons_max_a.bmp";
		)
		else
		(
			imageFile += "filter_icons_maya";
			alphaImageFile += "filter_icons_maya_a.bmp";
		)
		
		if ((outliner.prefs.getValue #Visual #colorscheme) == "Dark" AND outliner.maxV < 12) do
			imageFile += "_dark";

		imageFile += ".bmp";
		
		for i = 1 to buttons.count do
		(
			local imgIndex = i * 2 - 1;
			-- ColorTheme feature was introduced after 3dsmax2010 (v12).
			if (outliner.maxV < 12) then
			(
				buttons[i].images = #(imageFile, alphaImageFile, 11 * 2, imgIndex + 1, imgIndex, imgIndex + 1, imgIndex);
			)
			else
				buttons[i].images = #(imageFile, undefined, 11 * 2, imgIndex + 1, imgIndex, imgIndex + 1, imgIndex, true, true);
		)
	)
	
	
	-- Set button images on dialog open.
	on outliner_filter_config open do
	(
		if (checkOutlinerStatus()) do
		(
			-- Note: Button, filter and hidebycategory reference indices must correspond for functions to work correctly!
			buttons = #(filter_go, filter_sh, filter_li,
					    filter_ca, filter_he, filter_sw,
						filter_bo, filter_pa, filter_xr, 
					  	filter_hi, filter_fr);
		
			treeFilter = outliner.tree.Filter;
			filter_refs = #(&treeFilter.showGeometry, &treeFilter.showShapes, &treeFilter.showLights,
							&treeFilter.showCameras, &treeFilter.showHelpers, &treeFilter.showSpaceWarps,
							&treeFilter.showBones, &treeFilter.showParticles, &treeFilter.showXRefs,
							&treeFilter.showHidden, &treeFilter.showFrozen);
							  
			hideByCat_refs = #(&hideByCategory.geometry, &hideByCategory.shapes, &hideByCategory.lights,
							   &hideByCategory.cameras, &hideByCategory.helpers, &hideByCategory.spacewarps,
							   &hideByCategory.bones, &hideByCategory.particles);
	
			setButtonImages();
			setButtonStates();
		)
	)
)