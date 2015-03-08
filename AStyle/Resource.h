#ifndef	RES_INCLUDE
#define RES_INCLUDE

#include <d3d9.h>
#include <d3dx9.h>
#include <vector>
using std::vector;
#include <windows.h>
#include <d3d9.h>
#include <d3dx9.h>
#include <cstdio>
#include <shlobj.h>
#include "float2.h"
#include "float3.h"
#include "float4x4.h"

#if BUILDING_DLL
#define DLLIMPORT __declspec(dllexport)
#else
#define DLLIMPORT __declspec(dllimport)
#endif

// All global parameters
namespace Globals {
	extern DLLIMPORT class Renderer* renderer = NULL;
	extern DLLIMPORT class Camera* camera = NULL;
	extern DLLIMPORT class Interface* ui = NULL;
	extern DLLIMPORT class Scene* scene = NULL;
	extern DLLIMPORT class Models* models = NULL;
	extern DLLIMPORT class Textures* textures = NULL;
	extern DLLIMPORT class Options* options = NULL;
	extern DLLIMPORT class Console* console = NULL;
	extern DLLIMPORT LPD3DXEFFECT FX; // shader interface
	extern DLLIMPORT LPDIRECT3DDEVICE9 d3ddev; // d3d interface to graphics card
	extern DLLIMPORT HWND hwnd = NULL; // main window
	extern DLLIMPORT char exepath[MAX_PATH] = ""; // current directory
}

// All global utilities
namespace Utils {
	void InitEngine();
	void DeleteEngine();
	vector<float3> ComputeSSAOKernel(int size);
	vector<float3> ComputeGaussKernel(int size,float sigma2);
	float RandomRange(float min,float max);
	char* ExtractFileName(const char* text,char* result);
	char* ExtractFilePath(const char* text,char* result);
	char* ExtractFileExt(const char* text,char* result);
	char* ChangeFileExt(const char* text,const char* newext,char* result);
	void GetCPUName(char* result,int size);
	void GetGPUName(char* result,int size);
	int GetFontSizePt(int points,HDC hdc);
	void GetCSIDLPath(int csidl,char* result);
	void SafeRelease(IUnknown* resource);
	int CountChar(const char* text,char token);
	char* TrimLeft(char* text);
	char* TrimRight(char* text);
	char* Trim(char* text);
	bool FileExists(const char* path);
	float DegToRad(float degin);
	float RadToDeg(float radin);
	void EnumerateFiles(const char* folder,const char* filter,std::vector<char*>* list);
	unsigned int Faculty(unsigned int n);
	unsigned int Binomial(unsigned int n,unsigned int k);
	float3 GramSchmidt2(float3 v1,float3 x2);
	float3 GramSchmidt3(float3 v1,float3 v2,float3 x3);
	bool fequals(float x1,float x2);
	float4x4 LookAt(const D3DXVECTOR3& from,const D3DXVECTOR3& to);
	void GetFullPath(const char* file,const char* folder,char* fullpath);
	char* StripQuotes(const char* text);
}
#endif
