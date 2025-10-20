const ping = require("ping");

/**
 * Ping a host and return the status
 * @param {string} host - IP address or hostname to ping
 * @param {number} count - Number of ping attempts (default: 4)
 * @returns {Promise<object>} Ping results
 */
async function pingHost(host, count = 4) {
  try {
    const config = {
      timeout: 5,
      extra: ["-n", count.toString()], // Windows specific
    };

    const result = await ping.promise.probe(host, config);

    return {
      host: host,
      alive: result.alive,
      time: result.time,
      min: result.min,
      max: result.max,
      avg: result.avg,
      packetLoss: result.packetLoss,
      output: result.output,
    };
  } catch (error) {
    return {
      host: host,
      alive: false,
      error: error.message,
    };
  }
}

/**
 * Format ping results for WhatsApp message
 * @param {object} result - Ping result object
 * @returns {string} Formatted message
 */
function formatPingResult(result) {
  if (result.error) {
    return `❌ *Ping Failed*\n\nHost: ${result.host}\nError: ${result.error}`;
  }

  if (!result.alive) {
    return `❌ *Host Unreachable*\n\nHost: ${result.host}\nStatus: Offline/Unreachable`;
  }

  let message = `✅ *Ping Successful*\n\n`;
  message += `Host: ${result.host}\n`;
  message += `Status: Online\n`;
  message += `Response Time: ${result.time} ms\n`;

  if (result.min && result.max && result.avg) {
    message += `Min: ${result.min} ms\n`;
    message += `Max: ${result.max} ms\n`;
    message += `Avg: ${result.avg} ms\n`;
  }

  if (result.packetLoss) {
    message += `Packet Loss: ${result.packetLoss}\n`;
  }

  return message;
}

/**
 * Validate IP address or hostname
 * @param {string} host - IP address or hostname
 * @returns {boolean} True if valid
 */
function isValidHost(host) {
  // Check for valid IP address (IPv4)
  const ipv4Regex = /^(\d{1,3}\.){3}\d{1,3}$/;
  // Check for valid hostname
  const hostnameRegex =
    /^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$/;

  if (ipv4Regex.test(host)) {
    // Validate IP address octets are in range 0-255
    const octets = host.split(".");
    return octets.every((octet) => {
      const num = parseInt(octet, 10);
      return num >= 0 && num <= 255;
    });
  }

  return hostnameRegex.test(host);
}

module.exports = {
  pingHost,
  formatPingResult,
  isValidHost,
};
