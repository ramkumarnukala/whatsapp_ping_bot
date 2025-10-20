const { Client, LocalAuth } = require("whatsapp-web.js");
const qrcode = require("qrcode-terminal");
const { pingHost, formatPingResult, isValidHost } = require("./pingService");

// Initialize the WhatsApp client
console.log("Initializing WhatsApp client...");
const client = new Client({
  authStrategy: new LocalAuth(),
  puppeteer: {
    headless: true,
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage",
      "--disable-accelerated-2d-canvas",
      "--no-first-run",
      "--no-zygote",
      "--disable-gpu",
    ],
  },
});

console.log("Client created. Setting up event handlers...");

// Generate QR code for authentication
client.on("qr", (qr) => {
  console.log("\n📱 QR Code received! Scan this with your WhatsApp:\n");
  qrcode.generate(qr, { small: true });
  console.log(
    "\nOpen WhatsApp on your phone > Settings > Linked Devices > Link a Device"
  );
  console.log("Then scan the QR code above.\n");
});

// Client is ready
client.on("ready", () => {
  console.log("\n✅ WhatsApp Bot is ready!");
  console.log("You can now send ping commands to the bot.\n");
});

// Handle authentication
client.on("authenticated", () => {
  console.log("✅ Authenticated successfully!");
});

client.on("auth_failure", (msg) => {
  console.error("❌ Authentication failed:", msg);
});

// Add loading state
client.on("loading_screen", (percent, message) => {
  console.log(`Loading: ${percent}% - ${message}`);
});

// Add change state event
client.on("change_state", (state) => {
  console.log(`Connection state: ${state}`);
});

// Handle incoming messages
client.on("message", async (message) => {
  const chat = await message.getChat();
  const messageBody = message.body.trim();

  // Get sender info for logging
  const contact = await message.getContact();
  const chatType = chat.isGroup ? "GROUP" : "PRIVATE";
  const chatName = chat.name || "Unknown";

  console.log(
    `[${chatType}] Received message from ${
      contact.pushname || contact.number
    } in ${chatName}: ${messageBody}`
  );

  // Command: Help
  if (
    messageBody.toLowerCase() === "!help" ||
    messageBody.toLowerCase() === "/help"
  ) {
    const helpMessage =
      `🤖 *WhatsApp Ping Bot - Help*\n\n` +
      `Available commands:\n\n` +
      `*!ping <IP/hostname>* - Ping a host\n` +
      `  Example: !ping 192.168.1.1\n` +
      `  Example: !ping google.com\n\n` +
      `*!ping <IP/hostname> <count>* - Ping with custom count\n` +
      `  Example: !ping 192.168.1.1 10\n\n` +
      `*!help* - Show this help message\n\n` +
      `*!status* - Check bot status\n\n` +
      `_Note: This bot can ping devices in your private network._\n` +
      `_Works in both private chats and groups!_`;

    await chat.sendMessage(helpMessage);
    return;
  }

  // Command: Status
  if (messageBody.toLowerCase() === "!status") {
    const statusMessage =
      `✅ *Bot Status*\n\n` +
      `Status: Online and Running\n` +
      `Chat Type: ${chat.isGroup ? "Group" : "Private"}\n` +
      `Ready to ping hosts in your network!\n\n` +
      `Type *!help* for available commands.`;

    await chat.sendMessage(statusMessage);
    return;
  }

  // Command: Ping
  if (messageBody.toLowerCase().startsWith("!ping")) {
    const parts = messageBody.split(/\s+/);

    if (parts.length < 2) {
      await chat.sendMessage(
        "❌ Please provide an IP address or hostname.\n\nUsage: !ping <IP/hostname> [count]\nExample: !ping 192.168.1.1"
      );
      return;
    }

    const host = parts[1];
    const count = parts.length >= 3 ? parseInt(parts[2], 10) : 4;

    // Validate host
    if (!isValidHost(host)) {
      await chat.sendMessage(
        "❌ Invalid IP address or hostname.\n\nPlease provide a valid IPv4 address or hostname."
      );
      return;
    }

    // Validate count
    if (isNaN(count) || count < 1 || count > 20) {
      await chat.sendMessage(
        "❌ Invalid count. Please provide a number between 1 and 20."
      );
      return;
    }

    // Send initial message
    const requestedBy = chat.isGroup
      ? `@${message.author.split("@")[0]}`
      : "You";
    await chat.sendMessage(
      `🔍 Pinging ${host}... Please wait.\n_Requested by ${requestedBy}_`
    );

    try {
      // Perform ping
      const result = await pingHost(host, count);

      // Format and send result
      let resultMessage = formatPingResult(result);

      // Add requester info in groups
      if (chat.isGroup) {
        const contact = await message.getContact();
        resultMessage += `\n\n_Requested by: ${
          contact.pushname || contact.number
        }_`;
      }

      await chat.sendMessage(resultMessage);

      console.log(
        `Ping result for ${host}: ${result.alive ? "Online" : "Offline"}`
      );
    } catch (error) {
      console.error("Error during ping:", error);
      await chat.sendMessage(
        `❌ An error occurred while pinging ${host}.\n\nError: ${error.message}`
      );
    }

    return;
  }

  // Unknown command
  if (messageBody.startsWith("!") || messageBody.startsWith("/")) {
    await chat.sendMessage(
      "❓ Unknown command. Type *!help* to see available commands."
    );
  }
});

// Handle disconnection
client.on("disconnected", (reason) => {
  console.log("❌ Client was disconnected:", reason);
});

// Error handling
client.on("error", (error) => {
  console.error("❌ Client error:", error);
});

// Initialize the client
console.log("🚀 Starting WhatsApp Ping Bot...");
console.log("Launching browser and connecting to WhatsApp Web...");
console.log("This may take 10-30 seconds. Please wait...\n");

client.initialize().catch((err) => {
  console.error("❌ Failed to initialize client:", err);
  process.exit(1);
});

// Handle process termination
process.on("SIGINT", async () => {
  console.log("\n👋 Shutting down bot...");
  await client.destroy();
  process.exit(0);
});
