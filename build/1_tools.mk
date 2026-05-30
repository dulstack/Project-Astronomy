.PHONY: 1_tools download-1_tools tools-build 

TOOL_SUBMAKEFILES     = $(wildcard $(PWD)/build/tools/*.mk)
TOOL_PACKAGES         = $(TOOL_SUBMAKEFILES:$(PWD)/build/tools/%.mk=%)
TOOL_DOWNLOAD_TARGETS = $(TOOL_PACKAGES:%=download-%)
TOOLS_ROOT            = $(PWD)/$(OUT)/tools
TOOLS_CFLAGS          = -O2

include $(TOOL_SUBMAKEFILES)

1_tools: download-1_tools tools-build

download-1_tools: $(TOOL_DOWNLOAD_TARGETS)
tools-build: $(TOOL_PACKAGES)
