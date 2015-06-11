#include "headers/elements.hlsli"

float4 main(PixelShaderInput input) : SV_TARGET
{
	float2 normalized = input.origin * 0.5 + 0.5;
	uint2 intPos = uint2(round(normalized * float2(resolution)-0.5));

	uint _index = resolution.x * intPos.y + intPos.x;
	uint index = headers[_index].i;

	uint newIndex = index;

	int counter = 0;
	while (counter < 100 && index != 0xFFFFFFFF) {
		if (rays[index].applyed == 0 && rays[index].active == 1 && hits[index].meshID == primitiveID) {
			rays[index].origin += rays[index].direct * hits[index].distance;

			float3 normalized = -normalize(dot(rays[index].direct, hits[index].normal) * hits[index].normal);

			for (int i = 0;i < 1;i++) {
				Ray ray = rays[index];

				ray.direct = randomCosineWeightedDirectionInHemisphere(normalized, _index);
				ray.color *= pow(mcolor, 2.2);

				ray.origin += normalize(dot(ray.direct, hits[index].normal) * hits[index].normal) * 0.0001f;
				ray.applyed = 1;

				if (i == 0) {
					setRay(index, ray);
				}
				else {
					addRay(_index, ray);
				}
			}
		}
		index = rays[index].prev;
		counter++;
	}

	return float4(0.0, 0.0, 0.0, 0.0);
}