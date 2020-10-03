
include external/dvb/dvb.mk

$(call dvb_add_bundles, \
	rtl \
	external/rtl-reusables \
	)

include $(DVB_PILE_BEGIN)
DVB_NAME := conway-game-of-life
DVB_INCDIRS :=
DVB_DEFINES :=
DVB_REQUIRED := life reusables
include $(DVB_PILE_END)


define simulation
include $(DVB_SIMULATION_BEGIN)
DVB_NAME := $(1)
DVB_PILE := conway-game-of-life
DVB_TESTBENCH := sim/$(1)_tb.v
DVB_EXTRA_ARGS := +MEMORIES_DIR+$(realpath ./sim/memories)
ifeq ($(DVB_TOOLCHAIN),mentor)
DVB_EXTRA_ARGS += -do "log /$(1)_tb/u_arena/RAM;"
endif
DVB_WAVEFORM_VIEWER_CONFIG := sim/$(call dvb_cur_toolchain_waveform_viewer_config, $(1)_tb)
include $(DVB_SIMULATION_END)
endef

SIMULATIONS := \
	top \
	kernel \
	cell_reader \
	seeder \
	solver \


$(foreach sim,$(SIMULATIONS), \
	$(eval $(call simulation,$(sim))) \
)

