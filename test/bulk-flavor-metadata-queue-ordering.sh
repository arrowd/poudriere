#! /bin/sh

# first depends on a specific flavor
# second depends on the default flavor
# The order matters here since listed_ports does a sort -u. The specific
# FLAVOR dependency MUST come first to hit the bug.
LISTPORTS="ports-mgmt/poudriere-devel-dep-FOO ports-mgmt/zzzz"
. ${THISDIR}/common.bulk.sh

${SUDO} ${POUDRIEREPATH} -e ${POUDRIERE_ETC} bulk -n -CNt \
    -B "${BUILDNAME}" \
    -j "${JAILNAME}" -p "${PTNAME}" ${SETNAME:+-z "${SETNAME}"} \
    ${LISTPORTS}
assert 0 $? "Bulk should pass"

# Assert that only listed packages are in poudriere.ports.queued as 'listed'
assert_queued "listed" "${LISTPORTS}"

# Assert that all expected dependencies are in poudriere.ports.queued (since
# they do not exist yet)
expand_origin_flavors "${LISTPORTS}" expanded_LISTPORTS
list_all_deps "${expanded_LISTPORTS}" ALL_EXPECTED
assert_queued "" "${ALL_EXPECTED}"
