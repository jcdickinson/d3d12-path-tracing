#include "Content/shaders/headers/elements.hlsli"

float4 main(PixelShaderInput input) : SV_TARGET
{
	float2 normalized = input.origin * 0.5 + 0.5;
	uint2 intPos = uint2(round(normalized * float2(resolution)-0.5));

	uint _index = resolution.x * intPos.y + intPos.x;
	uint index = headers[_index].i;

	uint newIndex = index;

	int counter = 0;
	while (counter < 100 && index != 0xFFFFFFFF) {
		newIndex = index;

		if (rays[index].applyed == 0 && rays[index].active == 1 && hits[index].meshID == primitiveID) {
			float3 normalized = -normalize(dot(rays[index].direct, hits[index].normal) * hits[index].normal);

			rays[index].origin += rays[index].direct * hits[index].distance;

			//If normal, than we can do
			if (dot(rays[index].direct, hits[index].normal) < 0.0) {
				if (rays[index].origin.y > 1.0 - 0.0001f && length(rays[index].origin.xz) < 0.3) {
					rays[index].final = rays[index].color * pow(float3(1.0, 1.0, 1.0), 2.2) / pow(0.3, 2.0);
					rays[index].active = 0;
					rays[index].direct = randomCosineWeightedDirectionInHemisphere(normalized, _index);
					rays[index].origin += normalize(dot(rays[index].direct, hits[index].normal) * hits[index].normal) * 0.0001f;
					rays[index].applyed = 1;
				}
				else {
					Ray ray = rays[index];

					for (int i = 0;i < 1;i++) {
						ray = rays[index];

						ray.direct = randomCosineWeightedDirectionInHemisphere(normalized, _index);

						if (ray.origin.x > 1.0 - 0.0001f) {
							ray.color *= pow(float3(0.5, 0.5, 1.0), 2.2);
						}
						else
							if (ray.origin.x < -1.0 + 0.0001f) {
								ray.color *= pow(float3(1.0, 0.5, 0.5), 2.2);
							}
							else {
								ray.color *= pow(float3(1.0, 1.0, 1.0), 2.2);
							}

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
			}
		}
		index = rays[index].prev;
		counter++;
	}

	return float4(0.0, 0.0, 0.0, 0.0);
}