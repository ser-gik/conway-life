
include external/dvb/dvb.mk

$(call dvb_add_bundles, \
	rtl \
	)

include $(DVB_PILE_BEGIN)
DVB_NAME := conway-life
DVB_INCDIRS :=
DVB_DEFINES :=
DVB_REQUIRED := life
include $(DVB_PILE_END)


define simulation
include $(DVB_SIMULATION_BEGIN)
DVB_NAME := $(1)
DVB_PILE := conway-life
DVB_TESTBENCH := sim/$(1)_tb.v
DVB_WAVEFORM_VIEWER_CONFIG := sim/$(call dvb_cur_toolchain_waveform_viewer_config, $(1)_tb)
include $(DVB_SIMULATION_END)
endef

SIMULATIONS := \
	top \
	kernel \
	cell_reader \
	seeder \


$(foreach sim,$(SIMULATIONS), \
	$(eval $(call simulation,$(sim))) \
)

