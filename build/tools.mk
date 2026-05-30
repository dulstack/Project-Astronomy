.PHONY: tools download-tools tools-build 

TOOL_SUBMAKEFILES=$(wildcard $(PWD)/build/tools/*.mk)
TOOL_PACKAGES=$(TOOL_SUBMAKEFILES:$(PWD)/build/tools/%.mk=%)
TOOL_DOWNLOAD_TARGETS=$(TOOL_PACKAGES:%=download-%)
TOOLS_ROOT=$(PWD)/$(OUT)/tools

include $(TOOL_SUBMAKEFILES)

tools: download-tools tools-build

download-tools: $(TOOL_DOWNLOAD_TARGETS)
tools-build: $(TOOL_PACKAGES)
