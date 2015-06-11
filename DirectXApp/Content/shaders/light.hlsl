#include "headers/elements.hlsli"

float4 main(PixelShaderInput input) : SV_TARGET
{
	float2 normalized = input.origin * 0.5 + 0.5;
	uint2 intPos = uint2(round(normalized * float2(resolution)-0.5));

	uint _index = resolution.x * intPos.y + intPos.x;
	uint index = headers[_index].i;

	int counter = 0;
	while (counter < 100 && index != 0xFFFFFFFF) {
		if (rays[index].active == 1 && hits[index].meshID == primitiveID) {
			float3 normalized = -normalize(dot(rays[index].direct, hits[index].normal) * hits[index].normal);

			rays[index].origin += rays[index].direct * hits[index].distance;
			rays[index].direct = randomCosineWeightedDirectionInHemisphere(normalized, index);

			rays[index].final = rays[index].color * pow(mcolor, 2.2) / pow(0.2, 2.0) / 4.0;
			rays[index].active = 0;

			rays[index].origin += normalize(dot(rays[index].direct, normalized) * normalized) * 0.0001f;
		}
		index = rays[index].prev;
		counter++;
	}

	return float4(0.0, 0.0, 0.0, 0.0);
}