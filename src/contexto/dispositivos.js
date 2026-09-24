/**
 * dispositivos.js
 * Single source of truth for all 8 IPEX5001 input devices.
 *
 * Each device declares its hardware identity, connected equipment,
 * visual identity (color), and fallback capability profile for when
 * the Arranger auto-detection is unreachable.
 *
 * Components query this registry via helpers instead of hardcoding
 * device lists.
 */

export const DISPOSITIVOS = {
  DTV1: {
    id: 'DTV1',
    hardware: 'IPEX5001',
    mac: 'AA00000000001',
    connected: 'DirecTV HD Decoder',
    provider: 'DirecTV',
    defaultChannel: 1603,
    color: '#EF9A9A',
    fallbackCapabilities: [
      'videoSource',
      'audioSource',
      'channelControl',
      'serialGateway',
    ],
  },
  DTV2: {
    id: 'DTV2',
    hardware: 'IPEX5001',
    mac: 'AA00000000002',
    connected: 'DirecTV HD Decoder',
    provider: 'DirecTV',
    defaultChannel: 1604,
    color: '#EC407A',
    fallbackCapabilities: ['videoSource', 'audioSource', 'channelControl'],
  },
  DTV3: {
    id: 'DTV3',
    hardware: 'IPEX5001',
    mac: 'AA00000000003',
    connected: 'DirecTV HD Decoder',
    provider: 'DirecTV',
    defaultChannel: 1605,
    color: '#7E57C2',
    fallbackCapabilities: ['videoSource', 'audioSource', 'channelControl'],
  },
  DTV4: {
    id: 'DTV4',
    hardware: 'IPEX5001',
    mac: 'AA00000000004',
    connected: 'DirecTV HD Decoder',
    provider: 'DirecTV',
    defaultChannel: 1608,
    color: '#42A5F5',
    fallbackCapabilities: ['videoSource', 'audioSource', 'channelControl'],
  },
  DTV5: {
    id: 'DTV5',
    hardware: 'IPEX5001',
    mac: 'AA00000000005',
    connected: 'DirecTV HD Decoder',
    provider: 'DirecTV',
    defaultChannel: 1621,
    color: '#66BB6A',
    fallbackCapabilities: ['videoSource', 'audioSource', 'channelControl'],
  },
  DTV6: {
    id: 'DTV6',
    hardware: 'IPEX5001',
    mac: 'AA00000000006',
    connected: 'DirecTV HD Decoder',
    provider: 'DirecTV',
    defaultChannel: 1629,
    color: '#FFEE58',
    fallbackCapabilities: ['videoSource', 'audioSource', 'channelControl'],
  },
  DTV7: {
    id: 'DTV7',
    hardware: 'IPEX5001',
    mac: 'AA00000000007',
    connected: 'OBS Encoder',
    provider: null,
    defaultChannel: null,
    color: '#FFCA28',
    fallbackCapabilities: ['videoSource'],
  },
  DTV8: {
    id: 'DTV8',
    hardware: 'IPEX5001',
    mac: 'AA00000000008',
    connected: 'Streaming Device',
    provider: null,
    defaultChannel: null,
    color: '#BDBDBD',
    fallbackCapabilities: ['videoSource'],
  },
};

/**
 * Get a single device by its ID.
 * @param {string} id — e.g. 'DTV1'
 * @returns {object|undefined}
 */
export function getDevice(id) {
  return DISPOSITIVOS[id];
}

/**
 * Get all devices that have a specific fallback capability.
 * @param {string} cap — e.g. 'channelControl', 'videoSource', 'audioSource'
 * @returns {object[]}
 */
export function getByCapability(cap) {
  return Object.values(DISPOSITIVOS).filter((d) =>
    d.fallbackCapabilities.includes(cap),
  );
}

/**
 * Get all devices as an array.
 * @returns {object[]}
 */
export function getAllDevices() {
  return Object.values(DISPOSITIVOS);
}

/**
 * Get all device IDs.
 * @returns {string[]}
 */
export function getDeviceIds() {
  return Object.keys(DISPOSITIVOS);
}
