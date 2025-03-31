#ifndef GIT_VERSION_INFO_
#define GIT_VERSION_INFO_
#include <stdint.h>

typedef struct{
	uint8_t dirtyFlg;
	uint8_t gitCommit[];
}gitVerInfo_t;

gitVerInfo_t gitVerInfo = {
	.gitCommit = "30afa29",
	.dirtyFlg = 1
};

#endif
