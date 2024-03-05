Portrait Statues
================
_(a Crusader Kings III modding utility)_

This repository contains modified CK3 shaders and other mod files which implement single-material statue effects for portraits that work both in GUI and in court scene and can be controlled using simple triggers without any portrait environment or GUI hacks.
<a name="demo"></a>

![Animated GIF showing gold and marble statue effects in GUI portraits and court room](https://media.githubusercontent.com/media/terrapass/ck3-modutil-portrait-statues/master/docs/gh_portrait_statues.gif)

You can integrate this feature into your own mod by copying the files into your mod's file structure and making adjustments if necessary (see [Integrating into Your Mod](#integration)).
You can also load the contents of this repo as a separate mod in your playset to test it out, `mod/descriptor.mod` is provided for this purpose.

**The code has been updated to be compatible with CK3 version 1.12 (Scythe).**

This statue effects implementation has been extracted from [**Godherja: The Dying World**](https://steamcommunity.com/sharedfiles/filedetails/?id=2326030123) mod, for which it was originally developed.

Special thanks to **Buck (Elder Kings 2)** for pioneering the trick of smuggling technical information via portrait decal mip-maps, which this mod utility uses to enable statue effects without relying on environment hacks.
Thanks to **The Fallen Eagle** mod for coming up with material colors and values for limestone, stone and copper.

Table of Contents
-----------------
1. <a href="#description">Description</a>
2. <a href="#under-the-hood">Mod Files Overview</a>
3. <a href="#integration">Integrating into Your Mod</a>
4. <a href="#new-materials">Adding New Materials</a>

Description<a name="description"></a>
-----------
This is **Godherja** team's refinement of statue effects for GUI portraits previously used by **The Fallen Eagle** and **Princes of Darkness** mods.

The first iteration of portrait statue effects was based on creating separate portrait environments with fake lights to be read from shader and then selecting those environments from GUI via a custom localization. This approach had 2 significant flaws: it didn't work in court rooms - only in GUI portraits, and it required separate GUI hacks in every window where a statue portrait could appear, which made it quite verbose as well as painful from mod compatibility and vanilla patch merging standpoints.

The implementation presented in this repo instead relies on fake transparent portrait decals with marker pixels hidden at one of their mip levels - a similar approach to the one used by **Buck** for portrait effects in the **Elder Kings 2** mod. This allows us to address both of aforementioned limitations and control the application of any of the statue effects via simple triggers, without the need for any special treatment from GUI and working both in GUI portraits and in the court room scene.

The following statue materials are included in this repo (shown left to right on the following image): gold, marble, limestone, stone, copper, rusted copper.

![Several portraits of Duke Vratislav with various statue effects applied](https://media.githubusercontent.com/media/terrapass/ck3-modutil-portrait-statues/master/docs/statue_materials.png)

These materials can be freely modified or new ones can be added, as described <a href="#new-materials">below</a>.

Mod Files Overview<a name="under-the-hood"></a>
------------------
The setup for statue portraits consists of the following main parts.

1. Fake transparent portrait decals (aka *marker decals*) in [`gfx/models/portraits/decals/GH_markers`](https://github.com/terrapass/ck3-modutil-portrait-statues/tree/master/mod/gfx/models/portraits/decals/GH_markers) all of the same size (1024x1024) and format (BC3/DXT5 with mip-maps) as vanilla portrait decals.

Each of these decal `.dds` contains marker pixels at its 16x16 MIP6 level. Top-left pixel in each of them has the reserved RGBA value of `(0, 255, 0, 0)` (as specified by `GH_MARKER_TOP_LEFT_STATUE` shader constant in `GH_portrait_effects.fxh`) and indicates to the modified `portrait_decals.fxh` shader that this is a marker decal for a statue effect. Top-right pixels have different reserved RGBA values, depending on the desired statue material (as specified by [`GH_MARKER_TOP_RIGHT_STATUE_*`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/gfx/FX/GH_portrait_effects.fxh#L19) shader constants in `GH_portrait_effects.fxh`).

2. New and modified shader files in [`gfx/FX`](https://github.com/terrapass/ck3-modutil-portrait-statues/tree/master/mod/gfx/FX) implementing statue effect selection and rendering.

[`GH_portrait_effects.fxh`](https://github.com/terrapass/ck3-modutil-portrait-statues/tree/master/mod/gfx/FX/GH_portrait_effects.fxh) sets up reserved RGBA values for markers as well as the color and properties for various statue materials (see [`GH_TryApplyStatueEffect()`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/gfx/FX/GH_portrait_effects.fxh#L64)).

[`jomini/portrait_decals.fxh`](https://github.com/terrapass/ck3-modutil-portrait-statues/tree/master/mod/gfx/FX/jomini/portrait_decals.fxh) contains additional logic implementing the scanning of portrait decals in search for markers to determine which statue effect to apply, if any.

Finally, [`jomini/portrait.shader`](https://github.com/terrapass/ck3-modutil-portrait-statues/tree/master/mod/gfx/FX/jomini/portrait.shader) and [`court_scene.shader`](https://github.com/terrapass/ck3-modutil-portrait-statues/tree/master/mod/gfx/FX/court_scene.shader) contain modifications integrating the statue effects into character portrait shaders for GUI and court rooms respectively.

3. New genes for marker decals in [`common/genes/GH_genes_special_markers.txt`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/common/genes/GH_genes_special_markers.txt), based on the previously mentioned marker decal `.dds` used as diffuse decal textures.

4. Portrait modifiers controlling said genes for activating statue effects in [`gfx/portraits/portrait_modifiers/GH_portrait_effects.txt`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/gfx/portraits/portrait_modifiers/GH_portrait_effects.txt), one for each material, based on scripted triggers (though they can easily be replaced with arbitrary triggers directly in portrait modifiers themselves, if needed).

5. Placeholder scripted triggers in [`common/scripted_triggers/GH_portrait_effects_triggers.txt`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/common/scripted_triggers/GH_portrait_effects_triggers.txt), all taking character as the scope, which determine whether to apply a statue effect with a certain material to the given character in GUI portraits and court room scene.

As part of this repo's example code, they check for `GH_is_gold_statue`, `GH_is_marble_statue` etc. character variables, but this can be replaced with arbitrary checks. Alternatively, scripted triggers can be dropped entirely and all the checks performed directly in portrait modifier code, as mentioned before.

Integrating into Your Mod<a name="integration"></a>
-------------------------
Based on the structure described above, you can use the following steps to integrate portrait statue effects into your mod.

1. Copy over marker decal textures from [`gfx/models/portraits/decals/GH_markers`](https://github.com/terrapass/ck3-modutil-portrait-statues/tree/master/mod/gfx/models/portraits/decals/GH_markers). You can later create your own additional ones as described in <a href="#new-materials">Adding New Materials</a>.

2. Copy all of the shader files that don't yet exist in your mod from [`gfx/FX`](https://github.com/terrapass/ck3-modutil-portrait-statues/tree/master/mod/gfx/FX).
If your mod already has some of these shader files, you'll need to manually merge in changes from this repo's versions of these files into yours.

For convenience, all the changes (compared to vanilla) are marked with `MOD(godherja)` comments in shader files -
you can just search for this string and copy/replace all pieces of code surrounded by this comment.
<!--Additionally, `MOD(court-skybox)` comments in `court_scene.shader` mark changes providing support for sky rendering in court room scene.-->

3. Copy genes and portrait modifiers files from `common/genes` and `gfx/portraits/portrait_modifiers` into your mod. Optionally, edit portrait modifiers in [`gfx/portraits/portrait_modifiers/GH_portrait_effects.txt`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/gfx/portraits/portrait_modifiers/GH_portrait_effects.txt) to use the conditions you want for statue effects, instead of the included scripted triggers.

4. Optionally, copy scripted triggers for statues from `common/scripted_triggers` and edit them to use your own logic, if needed.

Adding New Materials<a name="new-materials"></a>
--------------------
You can use the following steps to add a new material. (Alternatively, you can replace any of the existing materials that you don't need with your own one - for that it's basically enough to edit a corresponding else-if in `GH_TryApplyStatueEffect()` as described in step 2 below.)

1. In `gfx/FX/GH_portrait_effects.fxh` shader file, define a new marker RGBA value as a new `GH_MARKER_TOP_RIGHT_STATUE_<your material>` shader constant in the [corresponding section](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/gfx/FX/GH_portrait_effects.fxh#L19), using existing constants as an example. Make sure your RGBA value doesn't repeat any of the existing ones.

2. In the same file, in the body of [`GH_TryApplyStatueEffect()`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/gfx/FX/GH_portrait_effects.fxh#L64) add another `else if` to the existing else-if chain, checking for your new marker constant and applying the desired `Diffuse` (color) and `Properties` (fake SSS, specular highlight, metalness, roughness) values for your new material, similarly to how it's done for rusty copper.
```cpp
else if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_COPPER_RUST))
{
	Diffuse    = float4(0.2, 1.0, 0.7, 1.0);
	Properties = float4(0.0, 0.0, 0.0, 0.0);
}
```

3. Create a fully transparent black 1024x1024 texture and save it as a BC3/DXT5 `.dds` with mip-maps to `gfx/models/portraits/decals/GH_markers`.

4. Using either built-in tools in GIMP or a separate application, such as `detach` and `stitch` utilities from [NVIDIA's Legacy Texture Tools](https://developer.nvidia.com/legacy-texture-tools) DDS Utilities, edit level 6 (16x16) mip-map of your new `.dds` texture and set its top-left pixel's RGBA value to `(0, 255, 0, 0)` and its top-right pixel - to the value you specified for your marker constant in `gfx/FX/GH_portrait_effects.fxh` multiplied by 255, then save changes to your `.dds`. 

If you are using Paint.NET to edit this mip map, make sure your pencil tool is set to "Overwrite", rather than "Normal" mode, so that the edited pixels get the exact values you entered. If you are using GIMP, make sure you're editing the top-right pixel of the level 6 mip-map, which is at coordinates `15, 0` while mip6 is selected, rather than the top-right pixel of the entire image.

5. Add a gene and a portrait modifier, using existing examples in [`common/genes/GH_genes_special_markers.txt`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/common/genes/GH_genes_special_markers.txt) and [`gfx/portraits/portrait_modifiers/GH_portrait_effects.txt`](https://github.com/terrapass/ck3-modutil-portrait-statues/blob/master/mod/gfx/portraits/portrait_modifiers/GH_portrait_effects.txt), and set up any triggers you need for applying this new statue material to character portraits.
