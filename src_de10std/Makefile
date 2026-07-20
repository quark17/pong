.PHONY: default
default:
	@echo 'The following targets are available:'
	@echo
	@echo '  check      Check that the Quartus warnings match expected'
	@echo '  clean      Remove Quartus generated files'
	@echo '  fullclean  Remove BSC and Quartus generated files'
	@echo

.PHONY: check
check:
	./checks/do_checks.sh

.PHONY: clean
clean:
	$(RM) -rf output_files/ db/ incremental_db/
	$(RM) -f c5_pin_model_dump.txt PongDE10Std.qws

.PHONY: fullclean
fullclean: clean
	$(RM) -f mkFPGATopNoKbd_DE10Std.v
