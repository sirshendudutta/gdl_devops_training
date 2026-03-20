import {
  Paper,
  Stack,
  Typography,
} from "@mui/material";
import { Dns } from "@mui/icons-material";

export type InstanceInfo = {
  hostname: string;
  instanceId: string | null;
  privateIp: string | null;
  availabilityZone: string | null;
};

type InstanceDetailsCardProps = {
  instanceInfo: InstanceInfo;
};

const displayValue = (value: string | null | undefined) =>
  value && value.trim() !== "" ? value : "Unavailable";

export default function InstanceDetailsCard({
  instanceInfo,
}: InstanceDetailsCardProps) {
  return (
    <Paper sx={{ p: 3 }}>
      <Stack spacing={2}>
        <Stack direction="row" spacing={1} alignItems="center">
          <Dns color="primary" />
          <Typography variant="h6">Instance details</Typography>
        </Stack>
        <Typography variant="body2" color="text.secondary">
          Highlights which instance served this request.
        </Typography>
        <Stack direction={{ xs: "column", sm: "row" }} spacing={3}>
          <Stack spacing={0.5}>
            <Typography variant="caption" color="text.secondary">
              Hostname
            </Typography>
            <Typography>{displayValue(instanceInfo.hostname)}</Typography>
          </Stack>
          <Stack spacing={0.5}>
            <Typography variant="caption" color="text.secondary">
              Instance ID
            </Typography>
            <Typography>{displayValue(instanceInfo.instanceId)}</Typography>
          </Stack>
          <Stack spacing={0.5}>
            <Typography variant="caption" color="text.secondary">
              Private IP
            </Typography>
            <Typography>{displayValue(instanceInfo.privateIp)}</Typography>
          </Stack>
          <Stack spacing={0.5}>
            <Typography variant="caption" color="text.secondary">
              Availability Zone
            </Typography>
            <Typography>{displayValue(instanceInfo.availabilityZone)}</Typography>
          </Stack>
        </Stack>
      </Stack>
    </Paper>
  );
}
