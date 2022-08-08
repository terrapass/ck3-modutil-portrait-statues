PixelShader =
{
	Code [[
		// The general approach of encoding technical information via marker pixels in a decal mip-map
		// is adapted from a much more sophisticated implementation made by shader wizard Buck for EK2.

		//
		// Constants
		//

		// Marker enabling various effects is encoded via reserved RGBA values for top-left
		// and top-right pixels at this mip level of relevant decals' diffuse textures.
		static const int GH_MARKER_MIP_LEVEL = 6;

		static const float GH_MARKER_CHECK_TOLERANCE = 0.01f;

		static const float4 GH_MARKER_TOP_LEFT_STATUE = float4(0.0f, 1.0f, 0.0f, 0.0f);

		static const float4 GH_MARKER_TOP_RIGHT_STATUE_GOLD   = float4(1.0f, 0.0f, 0.0f, 0.0f);
		static const float4 GH_MARKER_TOP_RIGHT_STATUE_MARBLE = float4(0.0f, 1.0f, 0.0f, 0.0f);

		// ENUM: portrait effect type
		static const uint GH_PORTRAIT_EFFECT_TYPE_NONE   = 0;
		//static const uint GH_PORTRAIT_EFFECT_TYPE_FLAT   = 1;
		static const uint GH_PORTRAIT_EFFECT_TYPE_STATUE = 2;
		// END ENUM

		//
		// Types
		//

		struct GH_SMarkerTexels
		{
			float4 TopLeftTexel;
			float4 TopRightTexel;
		};

		struct GH_SPortraitEffect
		{
			uint   Type;
			float4 Param;
		};

		//
		// Interface
		//

		bool GH_MarkerTexelEquals(float4 MarkerTexel0, float4 MarkerTexel1)
		{
			return distance(MarkerTexel0, MarkerTexel1) < GH_MARKER_CHECK_TOLERANCE;
		}

		void GH_TryApplyStatueEffect(in GH_SPortraitEffect PortraitEffect, inout float4 Diffuse, inout float4 Properties)
		{
			if (PortraitEffect.Type != GH_PORTRAIT_EFFECT_TYPE_STATUE)
				return;

			if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_GOLD))
			{
				Diffuse    = float4(1.0, 0.8, 0.2, 1.0);
				Properties = float4(0.0, 1.0, 1.0, 0.0);
			}
			else if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_MARBLE))
			{
				Diffuse    = float4(1.0, 1.0, 1.0, 1.0);
				Properties = float4(0.0, 0.4, 0.25, 0.8);
			}
			else // Unrecognized material param
			{
				// Use some loud color like magenta to communicate the error
				Diffuse    = float4(1.0, 0.0, 1.0, 1.0);
				Properties = float4(1.0, 0.0, 0.0, 1.0);
			}
		}
	]]
}
